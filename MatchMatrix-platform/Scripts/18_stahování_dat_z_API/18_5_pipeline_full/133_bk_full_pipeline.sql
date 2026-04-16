-- ============================================================
-- 133_bk_full_pipeline.sql
-- MatchMatrix - BK full pipeline
--
-- Kam ulozit:
-- C:\MatchMatrix-platform\db\sql\133_bk_full_pipeline.sql
--
-- Jak spustit:
-- DBeaver -> otevrit soubor -> spustit cely script
--
-- Co dela:
-- 1) pripravi BK canonical teams z api_sport basketball
-- 2) opravi / doplni BK team_provider_map
-- 3) vytvori / potvrdi BK canonical ligu (Liga ACB, ext_league_id=117)
-- 4) vlozi BK fixtures do public.matches
-- 5) doplni league_id do BK matches
-- 6) udela kontrolni vystupy
--
-- Poznamka:
-- Tento script je zamerne BK-safe a pouziva sport-safe canonical identity:
-- public.teams.ext_source = 'api_sport_basketball'
-- aby se nemichaly sporty u multisport provideru api_sport.
-- ============================================================

-- ------------------------------------------------------------
-- 0) Doporuceni: explicitni commit hranice
-- ------------------------------------------------------------
BEGIN;

-- ------------------------------------------------------------
-- 1) BK source teams
--    bereme jen basketball z api_sport
--    1 radek na 1 external_team_id
-- ------------------------------------------------------------
DROP TABLE IF EXISTS tmp_bk_src_teams;

CREATE TEMP TABLE tmp_bk_src_teams AS
SELECT DISTINCT ON (s.external_team_id)
       s.external_team_id,
       s.team_name,
       s.external_league_id,
       s.season,
       s.provider,
       s.sport_code,
       s.updated_at
FROM staging.stg_provider_teams s
WHERE s.provider = 'api_sport'
  AND s.sport_code = 'basketball'
  AND s.external_team_id IS NOT NULL
  AND btrim(s.external_team_id) <> ''
  AND s.team_name IS NOT NULL
  AND btrim(s.team_name) <> ''
ORDER BY s.external_team_id, s.updated_at DESC NULLS LAST, s.team_name;

-- ------------------------------------------------------------
-- 2) Vytvor BK canonical teams, pokud jeste neexistuji
-- ------------------------------------------------------------
INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id
)
SELECT
    t.team_name,
    'api_sport_basketball',
    t.external_team_id
FROM tmp_bk_src_teams t
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams x
    WHERE x.ext_source = 'api_sport_basketball'
      AND x.ext_team_id = t.external_team_id
);

-- ------------------------------------------------------------
-- 3) Aliasy pro BK canonical teams
-- ------------------------------------------------------------
INSERT INTO public.team_aliases (
    team_id,
    alias,
    source
)
SELECT
    pt.id,
    src.team_name,
    'api_sport_basketball'
FROM tmp_bk_src_teams src
JOIN public.teams pt
  ON pt.ext_source = 'api_sport_basketball'
 AND pt.ext_team_id = src.external_team_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = pt.id
      AND lower(btrim(a.alias)) = lower(btrim(src.team_name))
);

-- ------------------------------------------------------------
-- 4) Oprava BK team_provider_map
--    smazeme jen BK provider ids a znovu je navazeme
--    na BK canonical teams
-- ------------------------------------------------------------
DELETE FROM public.team_provider_map m
WHERE m.provider = 'api_sport'
  AND m.provider_team_id IN (
      SELECT external_team_id
      FROM tmp_bk_src_teams
  );

INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id
)
SELECT
    pt.id,
    'api_sport',
    pt.ext_team_id
FROM public.teams pt
WHERE pt.ext_source = 'api_sport_basketball'
  AND EXISTS (
      SELECT 1
      FROM tmp_bk_src_teams s
      WHERE s.external_team_id = pt.ext_team_id
  )
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map m
      WHERE m.provider = 'api_sport'
        AND m.provider_team_id = pt.ext_team_id
  )
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map m2
      WHERE m2.team_id = pt.id
        AND m2.provider = 'api_sport'
  );

-- ------------------------------------------------------------
-- 5) BK canonical league
--    Zatim pracujeme s potvrzenou ligou 117 = Liga ACB
-- ------------------------------------------------------------
INSERT INTO public.leagues (
    sport_id,
    name,
    ext_source,
    ext_league_id
)
SELECT
    2,
    'Liga ACB',
    'api_sport_basketball',
    '117'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.leagues l
    WHERE l.ext_source = 'api_sport_basketball'
      AND l.ext_league_id = '117'
);

-- ------------------------------------------------------------
-- 6) BK source fixtures
--    jen basketball fixtures z api_sport
-- ------------------------------------------------------------
DROP TABLE IF EXISTS tmp_bk_src_fixtures;

CREATE TEMP TABLE tmp_bk_src_fixtures AS
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
WHERE f.provider = 'api_sport'
  AND f.sport_code = 'basketball';

-- ------------------------------------------------------------
-- 7) Vloz BK matches do public.matches
--    status mapping + score extraction
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
        WHEN f.status_text IN ('FT', 'AOT') THEN 'FINISHED'
        WHEN f.status_text IN ('NS', 'TBD') THEN 'SCHEDULED'
        WHEN f.status_text IN ('1Q', '2Q', '3Q', '4Q', 'HT', 'LIVE') THEN 'LIVE'
        WHEN f.status_text IN ('POSTP', 'PST') THEN 'POSTPONED'
        WHEN f.status_text IN ('CANC', 'CAN') THEN 'CANCELLED'
        ELSE 'SCHEDULED'
    END AS status,
    CASE
        WHEN f.status_text IN ('FT', 'AOT')
        THEN NULLIF(
               (
                 replace(
                   replace(f.home_score, '''', '"'),
                   'None',
                   'null'
                 )::jsonb ->> 'total'
               ),
               ''
             )::int
        ELSE NULL
    END AS home_score,
    CASE
        WHEN f.status_text IN ('FT', 'AOT')
        THEN NULLIF(
               (
                 replace(
                   replace(f.away_score, '''', '"'),
                   'None',
                   'null'
                 )::jsonb ->> 'total'
               ),
               ''
             )::int
        ELSE NULL
    END AS away_score,
    f.provider AS ext_source,
    f.external_fixture_id AS ext_match_id,
    2 AS sport_id
FROM tmp_bk_src_fixtures f
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
-- 8) Dopln league_id do BK matches
-- ------------------------------------------------------------
UPDATE public.matches m
SET league_id = l.id
FROM public.leagues l
WHERE l.ext_source = 'api_sport_basketball'
  AND l.ext_league_id = '117'
  AND m.ext_source = 'api_sport'
  AND m.sport_id = 2
  AND m.league_id IS NULL
  AND EXISTS (
      SELECT 1
      FROM tmp_bk_src_fixtures f
      WHERE f.external_fixture_id = m.ext_match_id
        AND f.external_league_id = '117'
  );

COMMIT;

-- ------------------------------------------------------------
-- 9) Kontroly po behu
-- ------------------------------------------------------------

-- BK canonical teams
SELECT
    count(*) AS bk_canonical_teams
FROM public.teams
WHERE ext_source = 'api_sport_basketball';

-- BK provider map
SELECT
    count(*) AS bk_team_provider_map_rows
FROM public.team_provider_map
WHERE provider = 'api_sport'
  AND provider_team_id IN (
      SELECT external_team_id
      FROM staging.stg_provider_teams
      WHERE provider = 'api_sport'
        AND sport_code = 'basketball'
  );

-- BK matches summary
SELECT
    ext_source,
    sport_id,
    status,
    count(*) AS cnt
FROM public.matches
WHERE ext_source = 'api_sport'
  AND sport_id = 2
GROUP BY ext_source, sport_id, status
ORDER BY cnt DESC, status;

-- BK league mapping summary
SELECT
    m.league_id,
    l.name AS league_name,
    count(*) AS cnt
FROM public.matches m
LEFT JOIN public.leagues l
    ON l.id = m.league_id
WHERE m.ext_source = 'api_sport'
  AND m.sport_id = 2
GROUP BY m.league_id, l.name
ORDER BY cnt DESC;

-- Posledni BK matches
SELECT
    id,
    ext_match_id,
    league_id,
    status,
    home_score,
    away_score
FROM public.matches
WHERE ext_source = 'api_sport'
  AND sport_id = 2
ORDER BY id DESC
LIMIT 20;