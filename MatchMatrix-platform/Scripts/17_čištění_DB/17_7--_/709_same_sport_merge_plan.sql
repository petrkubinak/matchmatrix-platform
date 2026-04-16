-- 709_same_sport_merge_plan.sql

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
grouped AS (
    SELECT
        LOWER(TRIM(t.name)) AS team_name_norm,
        ts.sport_code,
        MIN(t.id) AS keep_team_id,
        COUNT(DISTINCT t.id) AS team_count
    FROM public.teams t
    JOIN team_sports ts
      ON ts.team_id = t.id
    GROUP BY
        LOWER(TRIM(t.name)),
        ts.sport_code
    HAVING COUNT(DISTINCT t.id) > 1
),
members AS (
    SELECT
        g.team_name_norm,
        g.sport_code,
        g.keep_team_id,
        g.team_count,
        t.id AS candidate_team_id,
        t.name AS candidate_team_name
    FROM grouped g
    JOIN public.teams t
      ON LOWER(TRIM(t.name)) = g.team_name_norm
    JOIN team_sports ts
      ON ts.team_id = t.id
     AND ts.sport_code = g.sport_code
)
SELECT
    sport_code,
    team_name_norm,
    keep_team_id,
    candidate_team_id AS merge_from_team_id,
    candidate_team_name,
    team_count
FROM members
WHERE candidate_team_id <> keep_team_id
ORDER BY
    team_count DESC,
    sport_code,
    team_name_norm,
    merge_from_team_id;