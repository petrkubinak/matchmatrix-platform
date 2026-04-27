-- 615_audit_vb_vs_volleyball.sql
-- Cíl: najít všechny výskyty sport_code = VB / volleyball pro api_volleyball

SELECT 'ops.ingest_targets' AS table_name, sport_code, provider, COUNT(*) AS rows_count
FROM ops.ingest_targets
WHERE provider = 'api_volleyball'
   OR sport_code IN ('VB', 'volleyball')
GROUP BY sport_code, provider

UNION ALL

SELECT 'ops.ingest_entity_plan' AS table_name, sport_code, provider, COUNT(*) AS rows_count
FROM ops.ingest_entity_plan
WHERE provider = 'api_volleyball'
   OR sport_code IN ('VB', 'volleyball')
GROUP BY sport_code, provider

UNION ALL

SELECT 'ops.provider_entity_coverage' AS table_name, sport_code, provider, COUNT(*) AS rows_count
FROM ops.provider_entity_coverage
WHERE provider = 'api_volleyball'
   OR sport_code IN ('VB', 'volleyball')
GROUP BY sport_code, provider

UNION ALL

SELECT 'ops.runtime_entity_audit' AS table_name, sport_code, provider, COUNT(*) AS rows_count
FROM ops.runtime_entity_audit
WHERE provider = 'api_volleyball'
   OR sport_code IN ('VB', 'volleyball')
GROUP BY sport_code, provider

UNION ALL

SELECT 'staging.stg_api_payloads' AS table_name, sport_code, provider, COUNT(*) AS rows_count
FROM staging.stg_api_payloads
WHERE provider = 'api_volleyball'
   OR sport_code IN ('VB', 'volleyball')
GROUP BY sport_code, provider

UNION ALL

SELECT 'staging.stg_provider_fixtures' AS table_name, sport_code, provider, COUNT(*) AS rows_count
FROM staging.stg_provider_fixtures
WHERE provider = 'api_volleyball'
   OR sport_code IN ('VB', 'volleyball')
GROUP BY sport_code, provider

UNION ALL

SELECT 'staging.stg_provider_teams' AS table_name, sport_code, provider, COUNT(*) AS rows_count
FROM staging.stg_provider_teams
WHERE provider = 'api_volleyball'
   OR sport_code IN ('VB', 'volleyball')
GROUP BY sport_code, provider

UNION ALL

SELECT 'staging.stg_provider_leagues' AS table_name, sport_code, provider, COUNT(*) AS rows_count
FROM staging.stg_provider_leagues
WHERE provider = 'api_volleyball'
   OR sport_code IN ('VB', 'volleyball')
GROUP BY sport_code, provider

ORDER BY table_name, sport_code, provider;