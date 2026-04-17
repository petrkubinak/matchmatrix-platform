-- =====================================================================
-- 267_safe_normalized_matches_only_from_current_no_exact.sql
-- Jen SAFE normalized shody nad aktualnim bucketem NO_EXACT_MATCH
-- =====================================================================

WITH unmapped_no_exact AS (
    SELECT DISTINCT
        s.provider,
        s.external_team_id,
        s.team_name,
        public.normalize_team_name(s.team_name) AS src_norm
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_football'
      AND COALESCE(s.sport_code, '') IN ('football', 'FB', '')
      AND NOT EXISTS (
          SELECT 1
          FROM public.team_provider_map m
          WHERE m.provider = s.provider
            AND m.provider_team_id = s.external_team_id
      )
      AND NOT EXISTS (
          SELECT 1
          FROM public.teams t
          WHERE LOWER(BTRIM(t.name)) = LOWER(BTRIM(s.team_name))
      )
),
canon AS (
    SELECT
        t.id AS team_id,
        t.name AS canonical_team_name,
        public.normalize_team_name(t.name) AS canon_norm
    FROM public.teams t
),
safe_matches AS (
    SELECT
        u.external_team_id,
        u.team_name,
        u.src_norm,
        c.team_id,
        c.canonical_team_name,
        c.canon_norm
    FROM unmapped_no_exact u
    JOIN canon c
      ON u.src_norm = c.canon_norm
)
SELECT
    external_team_id,
    team_name,
    src_norm,
    team_id,
    canonical_team_name,
    canon_norm
FROM safe_matches
ORDER BY team_name;