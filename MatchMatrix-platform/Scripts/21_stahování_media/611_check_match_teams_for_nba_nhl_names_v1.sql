-- check_match_teams_for_nba_nhl_names_v1.sql
-- Hledá týmy v public.matches podobné názvům z media layeru.

WITH names AS (
    SELECT unnest(ARRAY[
        'Anaheim',
        'Buffalo',
        'Colorado',
        'Lakers',
        'Minnesota',
        'Montreal',
        'Knicks',
        'Oklahoma',
        'Spurs',
        'Vegas',
        'Cavaliers',
        'Timberwolves',
        '76ers',
        'Warriors'
    ]) AS needle
),
match_teams AS (
    SELECT DISTINCT
        t.id,
        t.name,
        t.ext_source,
        t.ext_team_id,
        COUNT(m.id) OVER (PARTITION BY t.id) AS match_count
    FROM public.teams t
    JOIN public.matches m
      ON m.home_team_id = t.id
      OR m.away_team_id = t.id
)
SELECT
    n.needle,
    mt.id AS match_team_id,
    mt.name AS match_team_name,
    mt.ext_source,
    mt.ext_team_id,
    mt.match_count
FROM names n
LEFT JOIN match_teams mt
  ON lower(mt.name) LIKE '%' || lower(n.needle) || '%'
ORDER BY
    n.needle,
    mt.match_count DESC NULLS LAST,
    mt.name;