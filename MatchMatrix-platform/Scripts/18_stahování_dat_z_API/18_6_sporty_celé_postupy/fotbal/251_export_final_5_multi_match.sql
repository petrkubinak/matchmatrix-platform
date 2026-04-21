-- =====================================================================
-- 251_export_final_5_multi_match.sql
-- Finalni aktualni export zbyvajicich MULTI_MATCH kandidatu
-- =====================================================================

WITH stg AS (
    SELECT DISTINCT
        s.provider,
        s.external_team_id,
        s.team_name,
        LOWER(BTRIM(s.team_name)) AS team_name_norm
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_football'
      AND COALESCE(s.sport_code, '') IN ('football', 'FB', '')
),
cand AS (
    SELECT
        stg.provider,
        stg.external_team_id,
        stg.team_name,
        t.id AS candidate_team_id,
        t.name AS candidate_team_name
    FROM stg
    JOIN public.teams t
      ON LOWER(BTRIM(t.name)) = stg.team_name_norm
),
agg AS (
    SELECT
        provider,
        external_team_id,
        team_name,
        COUNT(*) AS candidate_count,
        STRING_AGG(candidate_team_id::text, ',' ORDER BY candidate_team_id) AS candidate_team_ids,
        STRING_AGG(candidate_team_name, ' | ' ORDER BY candidate_team_id) AS candidate_team_names
    FROM cand
    GROUP BY provider, external_team_id, team_name
)
SELECT
    provider,
    external_team_id,
    team_name,
    candidate_count,
    candidate_team_ids,
    candidate_team_names
FROM agg
WHERE candidate_count > 1
ORDER BY team_name;