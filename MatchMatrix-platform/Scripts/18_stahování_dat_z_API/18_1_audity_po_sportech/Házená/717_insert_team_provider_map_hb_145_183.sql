-- 717_insert_team_provider_map_hb_145_183.sql
-- Cíl:
-- Založit HB team_provider_map pro:
-- external_league_id = 145, 183
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
  AND s.external_league_id IN ('145', '183')
  AND s.season = '2024'
  AND COALESCE(TRIM(s.external_team_id), '') <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM public.team_provider_map tpm
      WHERE tpm.provider = 'api_handball'
        AND tpm.provider_team_id = s.external_team_id
  );

-- kontrola 1: souhrn po ligach
SELECT
    s.external_league_id,
    s.season,
    COUNT(*) AS provider_map_rows
FROM public.team_provider_map tpm
JOIN staging.stg_provider_teams s
  ON s.provider = 'api_handball'
 AND s.sport_code = 'handball'
 AND s.external_team_id = tpm.provider_team_id
WHERE tpm.provider = 'api_handball'
  AND s.external_league_id IN ('145', '183')
  AND s.season = '2024'
GROUP BY s.external_league_id, s.season
ORDER BY s.external_league_id, s.season;

-- kontrola 2: detail
SELECT
    tpm.team_id,
    t.name AS team_name,
    tpm.provider,
    tpm.provider_team_id,
    s.external_league_id,
    s.season,
    tpm.created_at,
    tpm.updated_at
FROM public.team_provider_map tpm
JOIN public.teams t
  ON t.id = tpm.team_id
JOIN staging.stg_provider_teams s
  ON s.provider = 'api_handball'
 AND s.sport_code = 'handball'
 AND s.external_team_id = tpm.provider_team_id
WHERE tpm.provider = 'api_handball'
  AND s.external_league_id IN ('145', '183')
  AND s.season = '2024'
ORDER BY s.external_league_id, t.name, tpm.provider_team_id;