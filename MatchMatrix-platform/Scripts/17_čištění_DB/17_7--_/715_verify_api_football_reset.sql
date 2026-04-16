-- 715_verify_api_football_reset.sql

SELECT 'matches' AS source_table, COUNT(*) AS row_count
FROM public.matches
WHERE ext_source = 'api_football'

UNION ALL
SELECT 'match_features', COUNT(*)
FROM public.match_features mf
JOIN public.matches m
  ON m.id = mf.match_id
WHERE m.ext_source = 'api_football'

UNION ALL
SELECT 'team_provider_map', COUNT(*)
FROM public.team_provider_map
WHERE provider = 'api_football'

UNION ALL
SELECT 'stg_provider_fixtures', COUNT(*)
FROM staging.stg_provider_fixtures
WHERE provider = 'api_football'

UNION ALL
SELECT 'stg_provider_teams', COUNT(*)
FROM staging.stg_provider_teams
WHERE provider = 'api_football'

UNION ALL
SELECT 'stg_provider_leagues', COUNT(*)
FROM staging.stg_provider_leagues
WHERE provider = 'api_football';