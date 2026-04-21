-- 707_insert_team_provider_map_hb_131_smoke.sql
-- Cíl:
-- Založit HB team_provider_map pro smoke test:
-- provider = api_handball
-- sport_code = handball
-- external_league_id = 131
-- season = 2024

INSERT INTO public.team_provider_map (
    team_id,
    provider,
    provider_team_id,
    created_at,
    updated_at
)
SELECT DISTINCT
    t.id AS team_id,
    'api_handball' AS provider,
    s.external_team_id AS provider_team_id,
    NOW(),
    NOW()
FROM staging.stg_provider_teams s
JOIN public.teams t
  ON t.ext_source = 'api_handball'
 AND t.ext_team_id = s.external_team_id
WHERE s.provider = 'api_handball'
  AND s.sport_code = 'handball'
  AND s.external_league_id = '131'
  AND s.season = '2024'
  AND COALESCE(TRIM(s.external_team_id), '') <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map tpm
      WHERE tpm.provider = 'api_handball'
        AND tpm.provider_team_id = s.external_team_id
  );

-- kontrola
SELECT
    tpm.team_id,
    t.name AS team_name,
    tpm.provider,
    tpm.provider_team_id,
    tpm.created_at,
    tpm.updated_at
FROM public.team_provider_map tpm
JOIN public.teams t
  ON t.id = tpm.team_id
WHERE tpm.provider = 'api_handball'
ORDER BY t.name, tpm.provider_team_id;