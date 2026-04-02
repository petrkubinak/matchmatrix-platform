-- QUERY 1
-- unmapped canonical teams

WITH mapped_leagues AS (
    SELECT
        clm.canonical_league_id,
        clm.provider_league_id AS api_league_id
    FROM public.canonical_league_map clm
    WHERE clm.provider = 'api_football'
      AND clm.canonical_league_id IN (5, 6, 26, 27, 28, 29, 30)
),
fd_teams AS (
    SELECT DISTINCT
        ml.canonical_league_id,
        l.name AS league_name,
        l.country,
        t.id AS canonical_team_id,
        t.name AS canonical_team_name
    FROM mapped_leagues ml
    JOIN public.leagues l
      ON l.id = ml.canonical_league_id
    JOIN public.matches m
      ON m.league_id = ml.canonical_league_id
    JOIN public.teams t
      ON t.id IN (m.home_team_id, m.away_team_id)
),
mapped_canonical AS (
    SELECT DISTINCT canonical_team_id
    FROM public.canonical_team_map
    WHERE provider = 'api_football'
)
SELECT
    country,
    league_name,
    canonical_team_id,
    canonical_team_name
FROM fd_teams
WHERE canonical_team_id NOT IN (SELECT canonical_team_id FROM mapped_canonical)
ORDER BY country, league_name, canonical_team_name, canonical_team_id;