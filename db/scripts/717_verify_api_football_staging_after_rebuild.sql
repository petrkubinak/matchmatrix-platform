-- 717_verify_api_football_staging_after_rebuild.sql

SELECT 'stg_provider_leagues' AS table_name, COUNT(*) AS row_count
FROM staging.stg_provider_leagues
WHERE provider = 'api_football'

UNION ALL
SELECT 'stg_provider_teams', COUNT(*)
FROM staging.stg_provider_teams
WHERE provider = 'api_football'

UNION ALL
SELECT 'stg_provider_fixtures', COUNT(*)
FROM staging.stg_provider_fixtures
WHERE provider = 'api_football';