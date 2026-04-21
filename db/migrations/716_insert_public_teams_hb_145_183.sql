-- 716_insert_public_teams_hb_145_183.sql
-- Cíl:
-- Založit canonical HB teams do public.teams
-- ze staging.stg_provider_teams pro:
-- external_league_id = 145, 183
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
  AND s.external_league_id IN ('145', '183')
  AND s.season = '2024'
  AND COALESCE(TRIM(s.team_name), '') <> ''
  AND COALESCE(TRIM(s.external_team_id), '') <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM public.teams t
      WHERE t.ext_source = 'api_handball'
        AND t.ext_team_id = s.external_team_id
  );

-- kontrola 1: souhrn po ligách
SELECT
    s.external_league_id,
    s.season,
    COUNT(*) AS public_teams_rows
FROM public.teams t
JOIN staging.stg_provider_teams s
  ON s.provider = 'api_handball'
 AND s.sport_code = 'handball'
 AND s.external_team_id = t.ext_team_id
WHERE t.ext_source = 'api_handball'
  AND s.external_league_id IN ('145', '183')
  AND s.season = '2024'
GROUP BY s.external_league_id, s.season
ORDER BY s.external_league_id, s.season;

-- kontrola 2: detail
SELECT
    t.id,
    t.name,
    t.ext_source,
    t.ext_team_id,
    s.external_league_id,
    s.season,
    t.created_at,
    t.updated_at
FROM public.teams t
JOIN staging.stg_provider_teams s
  ON s.provider = 'api_handball'
 AND s.sport_code = 'handball'
 AND s.external_team_id = t.ext_team_id
WHERE t.ext_source = 'api_handball'
  AND s.external_league_id IN ('145', '183')
  AND s.season = '2024'
ORDER BY s.external_league_id, t.name, t.ext_team_id;