-- 035_merge_teams_api_football.sql
-- Params:
--   :run_id

WITH tgt AS (
  SELECT
    it.canonical_league_id,
    it.provider_league_id,
    it.season
  FROM ops.ingest_targets it
  WHERE it.enabled = true
    AND it.sport_code = 'FOOTBALL'
    AND it.provider = 'api-football'
),
src AS (
  SELECT
    s.*,
    t.canonical_league_id
  FROM staging.api_football_teams s
  JOIN tgt t
    ON t.provider_league_id = s.league_id::text
   AND t.season = s.season::text
  WHERE s.run_id = :run_id
),
upserted_teams AS (
  INSERT INTO public.teams (name, ext_source, ext_team_id, created_at, updated_at)
  SELECT
    s.name,
    'api-football',
    s.team_id::text,
    now(), now()
  FROM src s
  ON CONFLICT (ext_source, ext_team_id)
  DO UPDATE SET
    name = EXCLUDED.name,
    updated_at = now()
  RETURNING id, ext_team_id
),
mapped AS (
  SELECT DISTINCT
    s.canonical_league_id,
    s.season::text AS season,
    t.id AS team_id
  FROM src s
  JOIN public.teams t
    ON t.ext_source = 'api-football'
   AND t.ext_team_id = s.team_id::text
),
ins_league_teams AS (
  INSERT INTO public.league_teams (league_id, team_id, season, created_at, updated_at)
  SELECT
    m.canonical_league_id,
    m.team_id,
    m.season,
    now(), now()
  FROM mapped m
  ON CONFLICT (league_id, team_id)
  DO UPDATE SET updated_at = now()
  RETURNING 1
),
ins_league_team_seasons AS (
  INSERT INTO public.league_team_seasons (league_id, team_id, season, created_at, updated_at)
  SELECT
    m.canonical_league_id,
    m.team_id,
    m.season,
    now(), now()
  FROM mapped m
  ON CONFLICT (league_id, team_id, season)
  DO NOTHING
  RETURNING 1
)
SELECT
  (SELECT count(*) FROM src)                     AS stg_rows,
  (SELECT count(*) FROM upserted_teams)          AS teams_upserted,
  (SELECT count(*) FROM ins_league_teams)        AS league_teams_touched,
  (SELECT count(*) FROM ins_league_team_seasons) AS league_team_seasons_inserted;