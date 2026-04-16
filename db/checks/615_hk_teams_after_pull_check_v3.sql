-- 615_hk_teams_after_pull_check_v3.sql

-- 1) RAW payloady v unified raw
SELECT
    'api_raw_payloads_hockey_teams' AS check_name,
    COUNT(*) AS cnt
FROM public.api_raw_payloads
WHERE LOWER(COALESCE(source, '')) LIKE '%hockey%'
   OR LOWER(COALESCE(endpoint, '')) LIKE '%hockey%'
   OR LOWER(COALESCE(endpoint, '')) LIKE '%teams%';

-- 2) HK legacy raw
SELECT
    'api_hockey_teams_raw' AS check_name,
    COUNT(*) AS cnt
FROM staging.api_hockey_teams_raw;

-- 3) HK parsed staging
SELECT
    'api_hockey_teams' AS check_name,
    COUNT(*) AS cnt
FROM staging.api_hockey_teams;

-- 4) Provider map pro hockey
SELECT
    'team_provider_map_hockey' AS check_name,
    COUNT(*) AS cnt
FROM public.team_provider_map
WHERE LOWER(provider) LIKE '%hockey%';

-- 5) Posledních 10 řádků z parsed HK staging
SELECT
    run_id,
    fetched_at,
    league_id,
    season,
    team_id,
    name
FROM staging.api_hockey_teams
ORDER BY fetched_at DESC
LIMIT 10;