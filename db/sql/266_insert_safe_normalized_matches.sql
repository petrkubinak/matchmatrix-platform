-- =====================================================================
-- 266_insert_safe_normalized_matches.sql
-- SAFE insert z normalized == normalized
-- =====================================================================

INSERT INTO public.team_provider_map (
    provider,
    provider_team_id,
    team_id,
    created_at,
    updated_at
)
SELECT
    'api_football',
    src.external_team_id,
    canon.team_id,
    NOW(),
    NOW()
FROM (
    SELECT DISTINCT
        s.external_team_id,
        public.normalize_team_name(s.team_name) AS src_norm
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_football'
      AND COALESCE(s.sport_code, '') IN ('football', 'FB', '')
      AND s.team_name ~ '\?'
) src
JOIN (
    SELECT
        t.id AS team_id,
        public.normalize_team_name(t.name) AS canon_norm
    FROM public.teams t
) canon
  ON src.src_norm = canon.canon_norm

WHERE NOT EXISTS (
    SELECT 1
    FROM public.team_provider_map m
    WHERE m.provider = 'api_football'
      AND m.provider_team_id = src.external_team_id
);