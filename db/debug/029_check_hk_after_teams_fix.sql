-- 029_check_hk_after_teams_fix.sql

SELECT
    'public.teams_hk' AS metric,
    COUNT(*)::bigint AS value
FROM public.teams t
JOIN public.team_provider_map m
  ON m.team_id = t.id
WHERE m.provider = 'api_hockey'

UNION ALL

SELECT
    'public.matches_hk',
    COUNT(*)::bigint
FROM public.matches
WHERE sport_id = 2

UNION ALL

SELECT
    'staging.stg_provider_teams_hk',
    COUNT(*)::bigint
FROM staging.stg_provider_teams
WHERE provider = 'api_hockey'

UNION ALL

SELECT
    'staging.stg_provider_fixtures_hk',
    COUNT(*)::bigint
FROM staging.stg_provider_fixtures
WHERE provider = 'api_hockey'
;