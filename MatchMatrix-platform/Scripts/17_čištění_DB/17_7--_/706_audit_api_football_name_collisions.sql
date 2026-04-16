-- 706_audit_api_football_name_collisions.sql

WITH stg AS (
    SELECT
        s.provider,
        s.external_team_id,
        s.team_name
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_football'
),
canon AS (
    SELECT
        t.id AS team_id,
        t.name AS canonical_team_name
    FROM public.teams t
),
name_matches AS (
    SELECT
        s.provider,
        s.external_team_id,
        s.team_name,
        c.team_id,
        c.canonical_team_name
    FROM stg s
    JOIN canon c
      ON LOWER(TRIM(c.canonical_team_name)) = LOWER(TRIM(s.team_name))
),
ranked AS (
    SELECT
        provider,
        external_team_id,
        team_name,
        COUNT(*) AS matched_canonical_count,
        STRING_AGG(team_id::text, ', ' ORDER BY team_id) AS candidate_team_ids
    FROM name_matches
    GROUP BY
        provider,
        external_team_id,
        team_name
)
SELECT *
FROM ranked
WHERE matched_canonical_count > 1
ORDER BY team_name, external_team_id;