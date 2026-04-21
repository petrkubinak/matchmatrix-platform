-- =====================================================================
-- 285_export_remaining_should_now_be_mappable.sql
-- Zjisti posledni zbyvajici SHOULD_NOW_BE_MAPPABLE pripad
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
mapped AS (
    SELECT
        m.provider,
        m.provider_team_id
    FROM public.team_provider_map m
    WHERE m.provider = 'api_football'
),
cand AS (
    SELECT
        stg.provider,
        stg.external_team_id,
        stg.team_name,
        t.id AS candidate_team_id,
        t.name AS candidate_team_name
    FROM stg
    LEFT JOIN public.teams t
      ON LOWER(BTRIM(t.name)) = stg.team_name_norm
),
agg AS (
    SELECT
        c.provider,
        c.external_team_id,
        c.team_name,
        COUNT(c.candidate_team_id) FILTER (WHERE c.candidate_team_id IS NOT NULL) AS candidate_count,
        STRING_AGG(c.candidate_team_id::text, ',' ORDER BY c.candidate_team_id) FILTER (WHERE c.candidate_team_id IS NOT NULL) AS candidate_team_ids,
        STRING_AGG(c.candidate_team_name, ' | ' ORDER BY c.candidate_team_id) FILTER (WHERE c.candidate_team_id IS NOT NULL) AS candidate_team_names
    FROM cand c
    GROUP BY c.provider, c.external_team_id, c.team_name
)
SELECT
    a.provider,
    a.external_team_id,
    a.team_name,
    a.candidate_count,
    a.candidate_team_ids,
    a.candidate_team_names
FROM agg a
LEFT JOIN mapped mp
  ON mp.provider = a.provider
 AND mp.provider_team_id = a.external_team_id
WHERE mp.provider_team_id IS NULL
  AND a.candidate_count = 1
ORDER BY a.team_name;