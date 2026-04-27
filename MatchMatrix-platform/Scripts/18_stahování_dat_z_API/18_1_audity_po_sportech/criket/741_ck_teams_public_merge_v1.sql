-- 741_ck_teams_public_merge_v1.sql

-- ======================================
-- 1) INSERT nové týmy do public.teams
-- ======================================

INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id,
    created_at,
    updated_at,
    logo_url
)
SELECT DISTINCT
    s.team_name,
    'api_cricket',
    s.external_team_id,
    now(),
    now(),
    NULL
FROM staging.stg_provider_teams s
LEFT JOIN public.team_provider_map tpm
    ON tpm.provider = s.provider
   AND tpm.provider_team_id = s.external_team_id
WHERE s.provider = 'api_cricket'
  AND s.sport_code = 'CK'
  AND tpm.team_id IS NULL;


-- ======================================
-- 2) INSERT mapování do public.team_provider_map
-- ======================================

INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id,
    created_at
)
SELECT
    t.id,
    'api_cricket',
    s.external_team_id,
    now()
FROM staging.stg_provider_teams s
JOIN public.teams t
    ON t.ext_source = 'api_cricket'
   AND t.ext_team_id = s.external_team_id
LEFT JOIN public.team_provider_map tpm
    ON tpm.provider = 'api_cricket'
   AND tpm.provider_team_id = s.external_team_id
WHERE s.provider = 'api_cricket'
  AND s.sport_code = 'CK'
  AND tpm.team_id IS NULL;