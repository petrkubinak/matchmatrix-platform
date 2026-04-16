-- ============================================================
-- 134_vb_full_pipeline.sql
-- MatchMatrix - VB full pipeline
--
-- Kam ulozit:
-- C:\MatchMatrix-platform\db\sql\134_vb_full_pipeline.sql
--
-- Co dela:
-- 1) pripravi VB canonical teams z api_volleyball
-- 2) doplni / opravi VB team_provider_map
-- 3) vytvori canonical VB ligu pro external_league_id=97
-- 4) vlozi VB fixtures do public.matches
-- 5) doplni league_id do VB matches
-- 6) vypise kontroly
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1) VB source teams
-- ------------------------------------------------------------
DROP TABLE IF EXISTS tmp_vb_src_teams;

CREATE TEMP TABLE tmp_vb_src_teams AS
SELECT DISTINCT ON (s.external_team_id)
       s.external_team_id,
       s.team_name,
       s.external_league_id,
       s.season,
       s.provider,
       s.sport_code,
       s.updated_at
FROM staging.stg_provider_teams s
WHERE s.provider = 'api_volleyball'
  AND s.sport_code = 'volleyball'
  AND s.external_team_id IS NOT NULL
  AND btrim(s.external_team_id) <> ''
  AND s.team_name IS NOT NULL
  AND btrim(s.team_name) <> ''
ORDER BY s.external_team_id, s.updated_at DESC NULLS LAST, s.team_name;

-- ------------------------------------------------------------
-- 2) canonical VB teams
-- ------------------------------------------------------------
INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id
)
SELECT
    t.team_name,
    'api_volleyball',
    t.external_team_id
FROM tmp_vb_src_teams t
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams x
    WHERE x.ext_source = 'api_volleyball'
      AND x.ext_team_id = t.external_team_id
);

-- ------------------------------------------------------------
-- 3) VB aliases
-- ------------------------------------------------------------
INSERT INTO public.team_aliases (
    team_id,
    alias,
    source
)
SELECT
    pt.id,
    src.team_name,
    'api_volleyball'
FROM tmp_vb_src_teams src
JOIN public.teams pt
  ON pt.ext_source = 'api_volleyball'
 AND pt.ext_team_id = src.external_team_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = pt.id
      AND lower(btrim(a.alias)) = lower(btrim(src.team_name))
);

-- ------------------------------------------------------------
-- 4) provider map
-- ------------------------------------------------------------
DELETE FROM public.team_provider_map m
WHERE m.provider = 'api_volleyball'
  AND m.provider_team_id IN (
      SELECT external_team_id
      FROM tmp_vb_src_teams
  );

INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id
)
SELECT
    pt.id,
    'api_volleyball',
    pt.ext_team_id
FROM public.teams pt
WHERE pt.ext_source = 'api_volleyball'
  AND EXISTS (
      SELECT 1
      FROM tmp_vb_src_teams s
      WHERE s.external_team_id = pt.ext_team_id
  )
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map m
      WHERE m.provider = 'api_volleyball'
        AND m.provider_team_id = pt.ext_team_id
  )
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map m2
      WHERE m2.team_id = pt.id
        AND m2.provider = 'api_volleyball'
  );

-- ------------------------------------------------------------
-- 5) canonical VB league
-- sport_id:
-- zatim pouzivame 7 pro VB -> uprav, pokud mas jine ID v public.sports
-- ------------------------------------------------------------
INSERT INTO public.leagues (
    sport_id,
    name,
    ext_source,
    ext_league_id
)
SELECT
    10,
    'VB League 97',
    'api_volleyball',
    '97'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.leagues l
    WHERE l.ext_source = 'api_volleyball'
      AND l.ext_league_id = '97'
);

-- ------------------------------------------------------------
-- 6) source fixtures
-- ------------------------------------------------------------
DROP TABLE IF EXISTS tmp_vb_src_fixtures;

CREATE TEMP TABLE tmp_vb_src_fixtures AS
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
WHERE f.provider = 'api_volleyball'
  AND f.sport_code = 'volleyball';

-- ------------------------------------------------------------
-- 7) merge VB fixtures do public.matches
-- score se ulozi jen pokud je to bezpecne cislo
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
    NULL AS league_id,
    mph.team_id AS home_team_id,
    mpa.team_id AS away_team_id,
    f.fixture_date::timestamp AS kickoff,
    CASE
        WHEN upper(coalesce(f.status_text, '')) IN ('FT', 'AOT', 'FINISHED') THEN 'FINISHED'
        WHEN upper(coalesce(f.status_text, '')) IN ('NS', 'TBD', 'SCHEDULED') THEN 'SCHEDULED'
        WHEN upper(coalesce(f.status_text, '')) IN ('LIVE', '1SET', '2SET', '3SET', '4SET', '5SET') THEN 'LIVE'
        WHEN upper(coalesce(f.status_text, '')) IN ('POSTP', 'PST', 'POSTPONED') THEN 'POSTPONED'
        WHEN upper(coalesce(f.status_text, '')) IN ('CANC', 'CAN', 'CANCELLED') THEN 'CANCELLED'
        ELSE 'SCHEDULED'
    END AS status,
    CASE
        WHEN upper(coalesce(f.status_text, '')) IN ('FT', 'AOT', 'FINISHED')
         AND coalesce(f.home_score, '') ~ '^\d+$'
        THEN f.home_score::int
        ELSE NULL
    END AS home_score,
    CASE
        WHEN upper(coalesce(f.status_text, '')) IN ('FT', 'AOT', 'FINISHED')
         AND coalesce(f.away_score, '') ~ '^\d+$'
        THEN f.away_score::int
        ELSE NULL
    END AS away_score,
    f.provider AS ext_source,
    f.external_fixture_id AS ext_match_id,
    10 AS sport_id
FROM tmp_vb_src_fixtures f
JOIN public.team_provider_map mph
    ON mph.provider = f.provider
   AND mph.provider_team_id = f.home_team_external_id
JOIN public.team_provider_map mpa
    ON mpa.provider = f.provider
   AND mpa.provider_team_id = f.away_team_external_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.matches m
    WHERE m.ext_source = f.provider
      AND m.ext_match_id = f.external_fixture_id
);

-- ------------------------------------------------------------
-- 8) dopln league_id do VB matches
-- ------------------------------------------------------------
UPDATE public.matches m
SET league_id = l.id
FROM public.leagues l
WHERE l.ext_source = 'api_volleyball'
  AND l.ext_league_id = '97'
  AND m.ext_source = 'api_volleyball'
  AND m.sport_id = 10
  AND m.league_id IS NULL
  AND EXISTS (
      SELECT 1
      FROM tmp_vb_src_fixtures f
      WHERE f.external_fixture_id = m.ext_match_id
        AND f.external_league_id = '97'
  );

COMMIT;

-- ------------------------------------------------------------
-- 9) kontroly
-- ------------------------------------------------------------

SELECT
    count(*) AS vb_canonical_teams
FROM public.teams
WHERE ext_source = 'api_volleyball';

SELECT
    count(*) AS vb_team_provider_map_rows
FROM public.team_provider_map
WHERE provider = 'api_volleyball'
  AND provider_team_id IN (
      SELECT external_team_id
      FROM staging.stg_provider_teams
      WHERE provider = 'api_volleyball'
        AND sport_code = 'volleyball'
  );

SELECT
    ext_source,
    sport_id,
    status,
    count(*) AS cnt
FROM public.matches
WHERE ext_source = 'api_volleyball'
  AND sport_id = 10
GROUP BY ext_source, sport_id, status
ORDER BY cnt DESC, status;

SELECT
    m.league_id,
    l.name AS league_name,
    count(*) AS cnt
FROM public.matches m
LEFT JOIN public.leagues l
    ON l.id = m.league_id
WHERE m.ext_source = 'api_volleyball'
  AND m.sport_id = 10
GROUP BY m.league_id, l.name
ORDER BY cnt DESC;

SELECT
    id,
    ext_match_id,
    league_id,
    status,
    home_score,
    away_score
FROM public.matches
WHERE ext_source = 'api_volleyball'
  AND sport_id = 10
ORDER BY id DESC
LIMIT 20;