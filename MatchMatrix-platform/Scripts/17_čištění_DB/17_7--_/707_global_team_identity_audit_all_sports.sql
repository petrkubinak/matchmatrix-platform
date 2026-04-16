-- 711_global_team_identity_audit_all_sports.sql

WITH stg AS (
    SELECT
        provider,
        sport_code,
        external_team_id,
        team_name,
        external_league_id,
        season
    FROM staging.stg_provider_teams
    WHERE team_name IS NOT NULL
      AND TRIM(team_name) <> ''
),
canon AS (
    SELECT
        id AS team_id,
        name AS canonical_team_name
    FROM public.teams
    WHERE name IS NOT NULL
      AND TRIM(name) <> ''
),
name_matches AS (
    SELECT
        s.provider,
        s.sport_code,
        s.external_team_id,
        s.team_name,
        s.external_league_id,
        s.season,
        c.team_id,
        c.canonical_team_name
    FROM stg s
    JOIN canon c
      ON LOWER(TRIM(c.canonical_team_name)) = LOWER(TRIM(s.team_name))
),
ranked AS (
    SELECT
        provider,
        sport_code,
        external_team_id,
        team_name,
        COUNT(DISTINCT team_id) AS matched_canonical_count,
        STRING_AGG(DISTINCT team_id::text, ', ' ORDER BY team_id::text) AS candidate_team_ids,
        STRING_AGG(DISTINCT COALESCE(external_league_id, ''), ', ' ORDER BY COALESCE(external_league_id, '')) AS leagues,
        STRING_AGG(DISTINCT COALESCE(season, ''), ', ' ORDER BY COALESCE(season, '')) AS seasons
    FROM name_matches
    GROUP BY
        provider,
        sport_code,
        external_team_id,
        team_name
)
SELECT
    provider,
    sport_code,
    external_team_id,
    team_name,
    matched_canonical_count,
    candidate_team_ids,
    leagues,
    seasons
FROM ranked
WHERE matched_canonical_count > 1
ORDER BY
    matched_canonical_count DESC,
    sport_code,
    provider,
    team_name,
    external_team_id;