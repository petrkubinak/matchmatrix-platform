-- 750_ck_backfill_missing_public_team_maps.sql

-- ======================================
-- 1) vložit chybějící CK týmy do public.teams
-- jen ty, které už jsou ve stagingu, ale nemají provider map
-- ======================================

INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id,
    created_at,
    updated_at,
    logo_url
)
SELECT
    s.team_name,
    'api_cricket',
    s.external_team_id,
    now(),
    now(),
    NULL
FROM staging.stg_provider_teams s
LEFT JOIN public.team_provider_map tpm
    ON tpm.provider = 'api_cricket'
   AND tpm.provider_team_id = s.external_team_id
LEFT JOIN public.teams t
    ON t.ext_source = 'api_cricket'
   AND t.ext_team_id = s.external_team_id
WHERE s.provider = 'api_cricket'
  AND s.sport_code = 'CK'
  AND tpm.team_id IS NULL
  AND t.id IS NULL;

-- ======================================
-- 2) vložit missing mapování do public.team_provider_map
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