-- check_media_team_duplicate_match_ids_v1.sql
-- Cíl:
-- Najít duplicitní týmy podle názvu:
-- A) team_id používaný v article_team_map
-- B) jiný team_id se stejným/similar názvem, který má zápasy

WITH article_teams AS (
    SELECT
        t.id AS media_team_id,
        t.name AS media_team_name,
        COUNT(DISTINCT atm.article_id) AS article_links
    FROM public.article_team_map atm
    JOIN public.teams t ON t.id = atm.team_id
    GROUP BY t.id, t.name
),
teams_with_matches AS (
    SELECT
        t.id AS match_team_id,
        t.name AS match_team_name,
        COUNT(DISTINCT m.id) AS match_count
    FROM public.teams t
    JOIN public.matches m
      ON m.home_team_id = t.id
      OR m.away_team_id = t.id
    GROUP BY t.id, t.name
)
SELECT
    at.media_team_id,
    at.media_team_name,
    at.article_links,
    twm.match_team_id,
    twm.match_team_name,
    twm.match_count
FROM article_teams at
LEFT JOIN teams_with_matches twm
  ON lower(twm.match_team_name) = lower(at.media_team_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.matches m
    WHERE m.home_team_id = at.media_team_id
       OR m.away_team_id = at.media_team_id
)
ORDER BY
    at.article_links DESC,
    at.media_team_name;