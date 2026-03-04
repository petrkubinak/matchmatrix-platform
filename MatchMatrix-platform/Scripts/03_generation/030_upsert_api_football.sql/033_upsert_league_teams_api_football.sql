-- 03_generation/033_upsert_league_teams_api_football.sql
-- Param: :run_id
-- Source: staging.api_football_fixtures

WITH lt AS (
  SELECT DISTINCT
    f.league_id::text AS provider_league_id,
    f.season::text AS season,
    f.home_team_id::text AS provider_team_id
  FROM staging.api_football_fixtures f
  WHERE f.run_id = :run_id

  UNION

  SELECT DISTINCT
    f.league_id::text AS provider_league_id,
    f.season::text AS season,
    f.away_team_id::text AS provider_team_id
  FROM staging.api_football_fixtures f
  WHERE f.run_id = :run_id
)
INSERT INTO public.league_teams (league_id, team_id, season)
SELECT
  lpm.league_id,
  tpm.team_id,
  lt.season
FROM lt
JOIN public.league_provider_map lpm
  ON lpm.provider = 'api_football'
 AND lpm.provider_league_id = lt.provider_league_id
JOIN public.team_provider_map tpm
  ON tpm.provider = 'api_football'
 AND tpm.provider_team_id = lt.provider_team_id
ON CONFLICT (league_id, team_id) DO UPDATE
SET
  season = EXCLUDED.season,
  updated_at = now();