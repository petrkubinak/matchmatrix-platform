-- 616_fix_vb_sport_code.sql
-- Cíl: sjednotit api_volleyball sport_code z 'volleyball' na 'VB'
-- Bezpečné: měníme jen provider = api_volleyball

BEGIN;

UPDATE staging.stg_api_payloads
SET sport_code = 'VB'
WHERE provider = 'api_volleyball'
  AND sport_code = 'volleyball';

UPDATE staging.stg_provider_fixtures
SET sport_code = 'VB'
WHERE provider = 'api_volleyball'
  AND sport_code = 'volleyball';

UPDATE staging.stg_provider_teams
SET sport_code = 'VB'
WHERE provider = 'api_volleyball'
  AND sport_code = 'volleyball';

COMMIT;

-- kontrola po změně
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

ORDER BY table_name, sport_code, provider;