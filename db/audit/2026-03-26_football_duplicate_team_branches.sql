-- MatchMatrix
-- Audit duplicitních team větví + usage v matches
-- Verze bez teams.sport_id
-- Spouštět v DBeaveru

WITH football_teams AS (
    SELECT
        t.id,
        t.name,
        t.ext_source,
        t.ext_team_id,
        lower(
            regexp_replace(
                regexp_replace(
                    regexp_replace(
                        t.name,
                        '\b(fc|afc|cf|sc|ac|club|calcio|cfc|bc)\b',
                        '',
                        'gi'
                    ),
                    '[^a-z0-9 ]',
                    '',
                    'gi'
                ),
                '\s+',
                ' ',
                'g'
            )
        ) AS norm_name
    FROM public.teams t
),
team_usage AS (
    SELECT home_team_id AS team_id, COUNT(*) AS match_cnt
    FROM public.matches
    GROUP BY home_team_id

    UNION ALL

    SELECT away_team_id AS team_id, COUNT(*) AS match_cnt
    FROM public.matches
    GROUP BY away_team_id
),
team_usage_sum AS (
    SELECT team_id, SUM(match_cnt) AS matches_used
    FROM team_usage
    GROUP BY team_id
)
SELECT
    ft.norm_name,
    ft.id,
    ft.name,
    ft.ext_source,
    ft.ext_team_id,
    COALESCE(tus.matches_used, 0) AS matches_used
FROM football_teams ft
LEFT JOIN team_usage_sum tus
  ON tus.team_id = ft.id
WHERE ft.norm_name IN (
    'arsenal',
    'bournemouth',
    'sporting clube de portugal',
    'ogc nice',
    'lille osc',
    'sporting clube de braga'
)
OR ft.norm_name IN (
    SELECT norm_name
    FROM football_teams
    GROUP BY norm_name
    HAVING COUNT(*) > 1
)
ORDER BY ft.norm_name, COALESCE(tus.matches_used, 0) DESC, ft.id;