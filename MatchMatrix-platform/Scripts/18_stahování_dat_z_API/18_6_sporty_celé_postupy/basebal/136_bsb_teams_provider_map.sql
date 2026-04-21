-- ============================================================
-- 136_bsb_teams_provider_map.sql
-- MatchMatrix - BSB teams -> canonical teams + provider_map
--
-- Kam ulozit:
-- C:\MatchMatrix-platform\db\sql\136_bsb_teams_provider_map.sql
--
-- Jak spustit:
-- DBeaver -> otevrit soubor -> spustit cely script
--
-- Co dela:
-- 1) vezme BSB teams ze staging.stg_provider_teams
-- 2) vytvori canonical teams pro api_baseball
-- 3) doplni team_aliases
-- 4) doplni team_provider_map
-- 5) vypise kontroly
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1) source rows
-- ------------------------------------------------------------
DROP TABLE IF EXISTS tmp_bsb_src_teams;

CREATE TEMP TABLE tmp_bsb_src_teams AS
SELECT DISTINCT
    provider,
    sport_code,
    external_team_id,
    team_name,
    country_name,
    external_league_id,
    season,
    raw_payload_id
FROM staging.stg_provider_teams
WHERE provider = 'api_baseball'
  AND sport_code = 'baseball'
  AND external_league_id = '1'
  AND season = '2024';

-- ------------------------------------------------------------
-- 2) canonical teams
-- ------------------------------------------------------------
INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id
)
SELECT
    s.team_name,
    'api_baseball',
    s.external_team_id
FROM tmp_bsb_src_teams s
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams t
    WHERE t.ext_source = 'api_baseball'
      AND t.ext_team_id = s.external_team_id
);

-- ------------------------------------------------------------
-- 3) aliases
-- ------------------------------------------------------------
INSERT INTO public.team_aliases (
    team_id,
    alias,
    source
)
SELECT
    t.id,
    s.team_name,
    'api_baseball'
FROM tmp_bsb_src_teams s
JOIN public.teams t
  ON t.ext_source = 'api_baseball'
 AND t.ext_team_id = s.external_team_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_aliases a
    WHERE a.team_id = t.id
      AND lower(btrim(a.alias)) = lower(btrim(s.team_name))
);

-- ------------------------------------------------------------
-- 4) provider map
-- ------------------------------------------------------------
INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id
)
SELECT
    t.id,
    'api_baseball',
    s.external_team_id
FROM tmp_bsb_src_teams s
JOIN public.teams t
  ON t.ext_source = 'api_baseball'
 AND t.ext_team_id = s.external_team_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_provider_map m
    WHERE m.provider = 'api_baseball'
      AND m.provider_team_id = s.external_team_id
);

COMMIT;

-- ------------------------------------------------------------
-- 5) kontroly
-- ------------------------------------------------------------
SELECT
    count(*) AS bsb_canonical_teams
FROM public.teams
WHERE ext_source = 'api_baseball';

SELECT
    count(*) AS bsb_provider_map_rows
FROM public.team_provider_map
WHERE provider = 'api_baseball';

SELECT
    t.id,
    t.name,
    t.ext_team_id
FROM public.teams t
WHERE t.ext_source = 'api_baseball'
ORDER BY t.name
LIMIT 50;