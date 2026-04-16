
-- 710_audit_api_football_reset_scope.sql

-- 1) team_provider_map
SELECT
    'team_provider_map' AS source_table,
    COUNT(*) AS row_count
FROM public.team_provider_map
WHERE provider = 'api_football'

UNION ALL

-- 2) matches, kde je ext_source = api_football
SELECT
    'matches' AS source_table,
    COUNT(*) AS row_count
FROM public.matches
WHERE ext_source = 'api_football'

UNION ALL

-- 3) staging fixtures
SELECT
    'stg_provider_fixtures' AS source_table,
    COUNT(*) AS row_count
FROM staging.stg_provider_fixtures
WHERE provider = 'api_football'

UNION ALL

-- 4) staging teams
SELECT
    'stg_provider_teams' AS source_table,
    COUNT(*) AS row_count
FROM staging.stg_provider_teams
WHERE provider = 'api_football'

UNION ALL

-- 5) staging leagues
SELECT
    'stg_provider_leagues' AS source_table,
    COUNT(*) AS row_count
FROM staging.stg_provider_leagues
WHERE provider = 'api_football';