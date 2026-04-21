-- =====================================================================
-- 265_safe_exact_normalized_matches.sql
-- Pouze 100% bezpečné match (normalized == normalized)
-- =====================================================================

WITH src AS (
    SELECT DISTINCT
        s.external_team_id,
        s.team_name,
        public.normalize_team_name(s.team_name) AS src_norm
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_football'
      AND COALESCE(s.sport_code, '') IN ('football', 'FB', '')
      AND s.team_name ~ '\?'
),
canon AS (
    SELECT
        t.id AS team_id,
        t.name AS canonical_team_name,
        public.normalize_team_name(t.name) AS canon_norm
    FROM public.teams t
)
SELECT
    src.external_team_id,
    src.team_name,
    src.src_norm,
    canon.team_id,
    canon.canonical_team_name,
    canon.canon_norm
FROM src
JOIN canon
  ON src.src_norm = canon.canon_norm
ORDER BY src.team_name;