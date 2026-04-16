-- 708_split_same_vs_cross_sport_collisions.sql

WITH team_sports AS (
    SELECT DISTINCT
        m.team_id,
        s.sport_code
    FROM public.team_provider_map m
    JOIN staging.stg_provider_teams s
      ON s.provider = m.provider
     AND s.external_team_id = m.provider_team_id
    WHERE s.sport_code IS NOT NULL
),
base AS (
    SELECT
        LOWER(TRIM(t.name)) AS team_name_norm,
        COUNT(DISTINCT t.id) AS team_ids,
        COUNT(DISTINCT ts.sport_code) AS sport_count,
        STRING_AGG(DISTINCT t.id::text, ', ' ORDER BY t.id::text) AS team_ids_list,
        STRING_AGG(DISTINCT ts.sport_code, ', ' ORDER BY ts.sport_code) AS sports
    FROM public.teams t
    LEFT JOIN team_sports ts
      ON ts.team_id = t.id
    GROUP BY LOWER(TRIM(t.name))
)
SELECT
    team_name_norm,
    team_ids,
    sport_count,
    COALESCE(sports, '') AS sports,
    team_ids_list,
    CASE
        WHEN COALESCE(sport_count, 0) <= 1 AND team_ids > 1 THEN 'SAME_SPORT_DUPLICATE'
        WHEN sport_count > 1 THEN 'CROSS_SPORT_COLLISION'
        ELSE 'OK'
    END AS problem_type
FROM base
WHERE team_ids > 1
ORDER BY
    problem_type DESC,
    team_ids DESC,
    team_name_norm;