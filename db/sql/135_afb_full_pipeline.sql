-- ============================================================
-- 135_afb_full_pipeline.sql
-- MatchMatrix - AFB full pipeline
--
-- Kam ulozit:
-- C:\MatchMatrix-platform\db\sql\140_afb_full_pipeline.sql
--
-- Jak spustit:
-- DBeaver -> otevrit soubor -> spustit cely script
--
-- Co dela:
-- 1) pripravi AFB canonical teams z api_american_football
-- 2) doplni / opravi AFB team_provider_map
-- 3) potvrdi / pripadne vytvori canonical AFB ligu NFL (ext_league_id=1)
-- 4) vlozi AFB fixtures do public.matches
-- 5) doplni league_id do AFB matches
-- 6) vypise kontroly
--
-- Poznamka:
-- AFB je uz runtime potvrzeny sport. Tento script je hlavne
-- finalni opakovatelny pipeline balicek stejneho typu jako BK/VB.
-- NFL canonical liga uz podle auditu existuje.
-- Teams "AFC" / "NFC" zatim NESKRyvame, aby script odpovidal
-- potvrzenemu runtime stavu. Pozdeji je muzeme resit jako
-- non-playable entity.
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 0) pomocny kontext
--    AFB sport_id bereme z existujici canonical NFL ligy
--    nebo z jiz existujicich AFB matches
-- ------------------------------------------------------------
DROP TABLE IF EXISTS tmp_afb_context;

CREATE TEMP TABLE tmp_afb_context AS
SELECT
    COALESCE(
        (
            SELECT l.sport_id
            FROM public.leagues l
            WHERE l.ext_source = 'api_american_football'
              AND l.ext_league_id = '1'
            ORDER BY l.id
            LIMIT 1
        ),
        (
            SELECT m.sport_id
            FROM public.matches m
            WHERE m.ext_source = 'api_american_football'
            ORDER BY m.id
            LIMIT 1
        )
    ) AS sport_id;

-- Bezpecnostni kontrola:
-- pokud by sport_id nevyslo, uvidis to hned tady
SELECT * FROM tmp_afb_context;

-- ------------------------------------------------------------
-- 1) AFB source teams
-- ------------------------------------------------------------
DROP TABLE IF EXISTS tmp_afb_src_teams;

CREATE TEMP TABLE tmp_afb_src_teams AS
SELECT DISTINCT ON (s.external_team_id)
       s.external_team_id,
       s.team_name,
       s.external_league_id,
       s.season,
       s.provider,
       s.sport_code,
       s.updated_at
FROM staging.stg_provider_teams s
WHERE s.provider = 'api_american_football'
  AND COALESCE(s.sport_code, 'AFB') IN ('AFB', 'american_football')
  AND s.external_team_id IS NOT NULL
  AND btrim(s.external_team_id) <> ''
  AND s.team_name IS NOT NULL
  AND btrim(s.team_name) <> ''
ORDER BY s.external_team_id, s.updated_at DESC NULLS LAST, s.team_name;

-- ------------------------------------------------------------
-- 2) canonical AFB teams
-- ------------------------------------------------------------
INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id
)
SELECT
    t.team_name,
    'api_american_football',
    t.external_team_id
FROM tmp_afb_src_teams t
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams x
    WHERE x.ext_source = 'api_american_football'
      AND x.ext_team_id = t.external_team_id
);

-- ------------------------------------------------------------
-- 3) AFB aliases
-- ------------------------------------------------------------
INSERT INTO public.team_aliases (
    team_id,
    alias,
    source
)
SELECT
    pt.id,
    src.team_name,
    'api_american_football'
FROM tmp_afb_src_teams src
JOIN public.teams pt
  ON pt.ext_source = 'api_american_football'
 AND pt.ext_team_id = src.external_team_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = pt.id
      AND lower(btrim(a.alias)) = lower(btrim(src.team_name))
);

-- ------------------------------------------------------------
-- 4) AFB provider map
-- ------------------------------------------------------------
DELETE FROM public.team_provider_map m
WHERE m.provider = 'api_american_football'
  AND m.provider_team_id IN (
      SELECT external_team_id
      FROM tmp_afb_src_teams
  );

INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id
)
SELECT
    pt.id,
    'api_american_football',
    pt.ext_team_id
FROM public.teams pt
WHERE pt.ext_source = 'api_american_football'
  AND EXISTS (
      SELECT 1
      FROM tmp_afb_src_teams s
      WHERE s.external_team_id = pt.ext_team_id
  )
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map m
      WHERE m.provider = 'api_american_football'
        AND m.provider_team_id = pt.ext_team_id
  )
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map m2
      WHERE m2.team_id = pt.id
        AND m2.provider = 'api_american_football'
  );

-- ------------------------------------------------------------
-- 5) canonical AFB league = NFL (ext_league_id=1)
--    liga by uz mela existovat, ale script ji umi i potvrdit
-- ------------------------------------------------------------
INSERT INTO public.leagues (
    sport_id,
    name,
    ext_source,
    ext_league_id
)
SELECT
    c.sport_id,
    'NFL',
    'api_american_football',
    '1'
FROM tmp_afb_context c
WHERE c.sport_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM public.leagues l
      WHERE l.ext_source = 'api_american_football'
        AND l.ext_league_id = '1'
  );

-- ------------------------------------------------------------
-- 6) AFB source fixtures
-- ------------------------------------------------------------
DROP TABLE IF EXISTS tmp_afb_src_fixtures;

CREATE TEMP TABLE tmp_afb_src_fixtures AS
SELECT
    f.id,
    f.provider,
    f.sport_code,
    f.external_fixture_id,
    f.external_league_id,
    f.season,
    f.home_team_external_id,
    f.away_team_external_id,
    f.fixture_date,
    f.status_text,
    f.home_score,
    f.away_score,
    f.raw_payload_id,
    f.created_at,
    f.updated_at
FROM staging.stg_provider_fixtures f
WHERE f.provider = 'api_american_football'
  AND COALESCE(f.sport_code, 'AFB') IN ('AFB', 'american_football');

-- ------------------------------------------------------------
-- 7) merge AFB fixtures do public.matches
--    score ulozime jen pokud je bezpecne cislo
-- ------------------------------------------------------------
INSERT INTO public.matches (
    league_id,
    home_team_id,
    away_team_id,
    kickoff,
    status,
    home_score,
    away_score,
    ext_source,
    ext_match_id,
    sport_id
)
SELECT
    l.id AS league_id,
    mph.team_id AS home_team_id,
    mpa.team_id AS away_team_id,
    f.fixture_date::timestamp AS kickoff,
    CASE
        WHEN upper(coalesce(f.status_text, '')) IN ('FT', 'FINISHED', 'AOT') THEN 'FINISHED'
        WHEN upper(coalesce(f.status_text, '')) IN ('NS', 'TBD', 'SCHEDULED', 'NOT STARTED') THEN 'SCHEDULED'
        WHEN upper(coalesce(f.status_text, '')) IN ('LIVE', '1Q', '2Q', '3Q', '4Q', 'OT', 'HT', 'HALFTIME') THEN 'LIVE'
        WHEN upper(coalesce(f.status_text, '')) IN ('POSTP', 'PST', 'POSTPONED') THEN 'POSTPONED'
        WHEN upper(coalesce(f.status_text, '')) IN ('CANC', 'CAN', 'CANCELLED') THEN 'CANCELLED'
        ELSE 'SCHEDULED'
    END AS status,
    CASE
        WHEN coalesce(f.home_score, '') ~ '^\d+$'
        THEN f.home_score::int
        ELSE NULL
    END AS home_score,
    CASE
        WHEN coalesce(f.away_score, '') ~ '^\d+$'
        THEN f.away_score::int
        ELSE NULL
    END AS away_score,
    f.provider AS ext_source,
    f.external_fixture_id AS ext_match_id,
    c.sport_id
FROM tmp_afb_src_fixtures f
JOIN public.team_provider_map mph
    ON mph.provider = f.provider
   AND mph.provider_team_id = f.home_team_external_id
JOIN public.team_provider_map mpa
    ON mpa.provider = f.provider
   AND mpa.provider_team_id = f.away_team_external_id
CROSS JOIN tmp_afb_context c
LEFT JOIN public.leagues l
    ON l.ext_source = 'api_american_football'
   AND l.ext_league_id = COALESCE(f.external_league_id, '1')
WHERE c.sport_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM public.matches m
      WHERE m.ext_source = f.provider
        AND m.ext_match_id = f.external_fixture_id
  );

-- ------------------------------------------------------------
-- 8) dopln league_id do AFB matches
--    NFL = ext_league_id 1
-- ------------------------------------------------------------
UPDATE public.matches m
SET league_id = 24867
WHERE m.ext_source = 'api_american_football'
  AND m.sport_id = 16
  AND m.league_id IS NULL;

-- ------------------------------------------------------------
-- 9) kontroly
-- ------------------------------------------------------------

-- AFB canonical teams
SELECT
    count(*) AS afb_canonical_teams
FROM public.teams
WHERE ext_source = 'api_american_football';

-- AFB provider map
SELECT
    count(*) AS afb_team_provider_map_rows
FROM public.team_provider_map
WHERE provider = 'api_american_football';

-- AFB matches summary
SELECT
    ext_source,
    sport_id,
    status,
    count(*) AS cnt
FROM public.matches
WHERE ext_source = 'api_american_football'
GROUP BY ext_source, sport_id, status
ORDER BY cnt DESC, status;

-- AFB league mapping summary
SELECT
    m.league_id,
    l.name AS league_name,
    count(*) AS cnt
FROM public.matches m
LEFT JOIN public.leagues l
    ON l.id = m.league_id
WHERE m.ext_source = 'api_american_football'
GROUP BY m.league_id, l.name
ORDER BY cnt DESC;

-- Posledni AFB matches
SELECT
    id,
    ext_match_id,
    league_id,
    status,
    home_score,
    away_score
FROM public.matches
WHERE ext_source = 'api_american_football'
ORDER BY id DESC
LIMIT 20;