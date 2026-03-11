-- 1) základní počty
SELECT 'leagues' AS metric, COUNT(*)::text AS value
FROM public.leagues
WHERE ext_source = 'api_sport'

UNION ALL

SELECT 'teams' AS metric, COUNT(*)::text AS value
FROM public.teams
WHERE ext_source = 'api_sport'

UNION ALL

SELECT 'matches' AS metric, COUNT(*)::text AS value
FROM public.matches
WHERE ext_source = 'api_sport'

UNION ALL

SELECT 'matches_without_league' AS metric, COUNT(*)::text AS value
FROM public.matches
WHERE ext_source = 'api_sport'
  AND league_id IS NULL

UNION ALL

SELECT 'matches_without_teams' AS metric, COUNT(*)::text AS value
FROM public.matches
WHERE ext_source = 'api_sport'
  AND (home_team_id IS NULL OR away_team_id IS NULL);