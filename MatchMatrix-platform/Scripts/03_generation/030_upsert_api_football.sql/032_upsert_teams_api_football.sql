-- 03_generation/032_upsert_teams_api_football.sql
-- Param: :run_id
-- Source: staging.api_football_fixtures (bez potřeby staging.api_football_teams)

WITH teams_src AS (
  SELECT DISTINCT
    f.home_team_id::text AS ext_team_id,
    COALESCE(to_jsonb(f)->>'home_team_name', 'Team ' || f.home_team_id::text) AS name
  FROM staging.api_football_fixtures f
  WHERE f.run_id = :run_id

  UNION

  SELECT DISTINCT
    f.away_team_id::text AS ext_team_id,
    COALESCE(to_jsonb(f)->>'away_team_name', 'Team ' || f.away_team_id::text) AS name
  FROM staging.api_football_fixtures f
  WHERE f.run_id = :run_id
),
upsert_teams AS (
  INSERT INTO public.teams (name, ext_source, ext_team_id)
  SELECT
    s.name,
    'api_football' AS ext_source,
    s.ext_team_id
  FROM teams_src s
  ON CONFLICT (ext_source, ext_team_id) DO UPDATE
  SET
    name = EXCLUDED.name,
    updated_at = now()
  RETURNING id, ext_team_id
)
INSERT INTO public.team_provider_map (provider, provider_team_id, team_id)
SELECT
  'api_football' AS provider,
  t.ext_team_id AS provider_team_id,
  t.id AS team_id
FROM public.teams t
JOIN teams_src s
  ON t.ext_source = 'api_football'
 AND t.ext_team_id = s.ext_team_id
ON CONFLICT (provider, provider_team_id) DO UPDATE
SET team_id = EXCLUDED.team_id;