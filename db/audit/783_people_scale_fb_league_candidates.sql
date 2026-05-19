/*
783_people_scale_fb_league_candidates.sql

Účel:
- najít FB ligy z api_football, které už jsou v public.leagues
- z nich vybereme první batch pro PEOPLE players pipeline
*/

SELECT
    l.id AS canonical_league_id,
    l.ext_source AS provider,
    'FB' AS sport_code,
    l.ext_league_id AS provider_league_id,
    l.name AS league_name,
    l.country,
    COUNT(m.id) AS public_matches_count
FROM public.leagues l
LEFT JOIN public.matches m
    ON m.league_id = l.id
WHERE l.ext_source = 'api_football'
  AND l.ext_league_id IS NOT NULL
GROUP BY
    l.id,
    l.ext_source,
    l.ext_league_id,
    l.name,
    l.country
ORDER BY public_matches_count DESC, l.name
LIMIT 30;