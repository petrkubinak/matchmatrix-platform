-- 714_safe_reset_api_football_with_match_features.sql
-- CONTROLLED RESET pouze pro api_football
-- včetně dependent table public.match_features

BEGIN;

-- ------------------------------------------------------------
-- 0) pomocná množina api_football matches
-- ------------------------------------------------------------
CREATE TEMP TABLE tmp_api_football_match_ids AS
SELECT id
FROM public.matches
WHERE ext_source = 'api_football';

-- ------------------------------------------------------------
-- 1) dependent data
-- ------------------------------------------------------------
DELETE FROM public.match_features
WHERE match_id IN (SELECT id FROM tmp_api_football_match_ids);

-- ------------------------------------------------------------
-- 2) samotné api_football matches
-- ------------------------------------------------------------
DELETE FROM public.matches
WHERE id IN (SELECT id FROM tmp_api_football_match_ids);

-- ------------------------------------------------------------
-- 3) team provider map jen pro api_football
-- ------------------------------------------------------------
DELETE FROM public.team_provider_map
WHERE provider = 'api_football';

-- ------------------------------------------------------------
-- 4) staging vrstvy
-- ------------------------------------------------------------
DELETE FROM staging.stg_provider_fixtures
WHERE provider = 'api_football';

DELETE FROM staging.stg_provider_teams
WHERE provider = 'api_football';

DELETE FROM staging.stg_provider_leagues
WHERE provider = 'api_football';

-- ------------------------------------------------------------
-- 5) úklid temp tabulky
-- ------------------------------------------------------------
DROP TABLE IF EXISTS tmp_api_football_match_ids;

COMMIT;