-- =========================================================
-- MATCHMATRIX MEDIA TEAM SUPPORT V1
-- Merge BK/HK teams from staging.stg_provider_teams to public.teams
-- =========================================================

INSERT INTO public.teams
(
    name,
    ext_source,
    ext_team_id,
    logo_url,
    created_at,
    updated_at
)
SELECT DISTINCT
    s.team_name AS name,
    s.provider AS ext_source,
    s.external_team_id AS ext_team_id,
    NULL AS logo_url,
    now() AS created_at,
    now() AS updated_at
FROM staging.stg_provider_teams s
WHERE s.provider IN ('api_sport', 'api_hockey')
  AND s.sport_code IN ('basketball', 'hockey')
  AND s.team_name IS NOT NULL
  AND s.external_team_id IS NOT NULL
ON CONFLICT DO NOTHING;