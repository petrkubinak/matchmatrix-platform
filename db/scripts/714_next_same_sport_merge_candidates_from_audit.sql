-- 714_next_same_sport_merge_candidates_from_audit.sql
-- Další dávka merge kandidátů přímo z current public.teams
-- bez závislosti na team_provider_map logice

WITH base AS (
    SELECT
        LOWER(TRIM(name)) AS team_name_norm,
        MIN(id) AS keep_team_id,
        COUNT(*) AS team_count
    FROM public.teams
    GROUP BY LOWER(TRIM(name))
    HAVING COUNT(*) > 1
),
members AS (
    SELECT
        b.team_name_norm,
        b.keep_team_id,
        b.team_count,
        t.id AS merge_from_team_id,
        t.name AS candidate_team_name
    FROM base b
    JOIN public.teams t
      ON LOWER(TRIM(t.name)) = b.team_name_norm
    WHERE t.id <> b.keep_team_id
)
SELECT
    team_name_norm,
    keep_team_id,
    merge_from_team_id,
    candidate_team_name,
    team_count
FROM members
WHERE keep_team_id NOT IN (13202, 13228, 13110)
  AND merge_from_team_id NOT IN (14578, 13255, 13615)
ORDER BY
    team_count DESC,
    team_name_norm,
    merge_from_team_id
LIMIT 30;