-- 908_validate_bk_core_ready.sql

SELECT
    'stg_provider_leagues' AS area,
    COUNT(*) AS rows_count
FROM staging.stg_provider_leagues
WHERE provider = 'api_sport'
  AND sport_code = 'BK'

UNION ALL

SELECT
    'stg_provider_teams',
    COUNT(*)
FROM staging.stg_provider_teams
WHERE provider = 'api_sport'
  AND sport_code = 'BK'

UNION ALL

SELECT
    'stg_provider_fixtures',
    COUNT(*)
FROM staging.stg_provider_fixtures
WHERE provider = 'api_sport'
  AND sport_code = 'BK'

UNION ALL

SELECT
    'public.leagues',
    COUNT(*)
FROM public.leagues
WHERE ext_source = 'api_sport'
  AND sport_id = 3

UNION ALL

SELECT
    'public.team_provider_map',
    COUNT(*)
FROM public.team_provider_map
WHERE provider = 'api_sport'

UNION ALL

SELECT
    'public.matches',
    COUNT(*)
FROM public.matches
WHERE ext_source = 'api_sport'
  AND sport_id = 3;