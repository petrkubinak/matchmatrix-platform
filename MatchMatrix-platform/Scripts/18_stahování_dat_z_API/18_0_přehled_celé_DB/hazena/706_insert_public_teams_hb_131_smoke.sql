-- 706_insert_public_teams_hb_131_smoke.sql
-- Cíl:
-- Založit canonical HB teams do public.teams
-- ze staging.stg_provider_teams pro:
-- provider = api_handball
-- sport_code = handball
-- external_league_id = 131
-- season = 2024

INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id,
    created_at,
    updated_at
)
SELECT DISTINCT
    s.team_name,
    'api_handball' AS ext_source,
    s.external_team_id AS ext_team_id,
    NOW(),
    NOW()
FROM staging.stg_provider_teams s
WHERE s.provider = 'api_handball'
  AND s.sport_code = 'handball'
  AND s.external_league_id = '131'
  AND s.season = '2024'
  AND COALESCE(TRIM(s.team_name), '') <> ''
  AND COALESCE(TRIM(s.external_team_id), '') <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM public.teams t
      WHERE t.ext_source = 'api_handball'
        AND t.ext_team_id = s.external_team_id
  );

-- kontrola
SELECT
    id,
    name,
    ext_source,
    ext_team_id,
    created_at,
    updated_at
FROM public.teams
WHERE ext_source = 'api_handball'
ORDER BY name, ext_team_id;