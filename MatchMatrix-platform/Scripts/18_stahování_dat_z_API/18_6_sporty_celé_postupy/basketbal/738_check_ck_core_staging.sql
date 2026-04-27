-- 738_check_ck_core_staging.sql

SELECT 'stg_api_payloads' AS source, entity_type, parse_status, COUNT(*) AS rows_count
FROM staging.stg_api_payloads
WHERE provider = 'api_cricket'
  AND sport_code = 'CK'
GROUP BY entity_type, parse_status

UNION ALL

SELECT 'stg_provider_fixtures' AS source, NULL AS entity_type, NULL AS parse_status, COUNT(*) AS rows_count
FROM staging.stg_provider_fixtures
WHERE provider = 'api_cricket'
  AND sport_code = 'CK'

UNION ALL

SELECT 'stg_provider_leagues' AS source, NULL AS entity_type, NULL AS parse_status, COUNT(*) AS rows_count
FROM staging.stg_provider_leagues
WHERE provider = 'api_cricket'
  AND sport_code = 'CK'

UNION ALL

SELECT 'stg_provider_teams' AS source, NULL AS entity_type, NULL AS parse_status, COUNT(*) AS rows_count
FROM staging.stg_provider_teams
WHERE provider = 'api_cricket'
  AND sport_code = 'CK';