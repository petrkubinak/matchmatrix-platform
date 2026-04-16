-- =====================================================================
-- 213_fb_team_provider_map_multi_match_export.sql
-- MatchMatrix - export FB MULTI_MATCH týmů pro canonical merge cleanup
-- =====================================================================

WITH unmapped AS (
    SELECT
        spt.external_team_id,
        spt.team_name,
        spt.country_name,
        spt.external_league_id,
        spt.season,
        LOWER(TRIM(spt.team_name)) AS team_name_norm
    FROM staging.stg_provider_teams spt
    LEFT JOIN public.team_provider_map tpm
           ON tpm.provider = spt.provider
          AND tpm.provider_team_id = spt.external_team_id
    WHERE spt.provider = 'api_football'
      AND spt.sport_code = 'football'
      AND tpm.team_id IS NULL
),
canon AS (
    SELECT
        t.id AS team_id,
        t.name,
        LOWER(TRIM(t.name)) AS canonical_name_norm
    FROM public.teams t
),
matched AS (
    SELECT
        u.external_team_id,
        u.team_name,
        u.country_name,
        u.external_league_id,
        u.season,
        COUNT(c.team_id) AS matched_canonical_count,
        STRING_AGG(c.team_id::text, ', ' ORDER BY c.team_id::text) AS candidate_team_ids
    FROM unmapped u
    LEFT JOIN canon c
           ON c.canonical_name_norm = u.team_name_norm
    GROUP BY
        u.external_team_id,
        u.team_name,
        u.country_name,
        u.external_league_id,
        u.season
)
SELECT
    external_team_id,
    team_name,
    country_name,
    external_league_id,
    season,
    matched_canonical_count,
    candidate_team_ids
FROM matched
WHERE matched_canonical_count > 1
ORDER BY matched_canonical_count DESC, team_name;