-- =====================================================================
-- 264_export_encoding_candidates_against_canonical.sql
-- Preview kandidatu pro encoding/broken-text pripady proti canonical teams
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
),
pairs AS (
    SELECT
        src.external_team_id,
        src.team_name,
        src.src_norm,
        canon.team_id,
        canon.canonical_team_name,
        canon.canon_norm
    FROM src
    JOIN canon
      ON canon.canon_norm LIKE '%' || src.src_norm || '%'
         OR src.src_norm LIKE '%' || canon.canon_norm || '%'
)
SELECT
    external_team_id,
    team_name,
    src_norm,
    team_id,
    canonical_team_name,
    canon_norm
FROM pairs
ORDER BY team_name, canonical_team_name;