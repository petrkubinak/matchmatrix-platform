-- 03_generation/034_upsert_matches_api_football.sql
-- Param: :run_id

INSERT INTO public.matches (
  league_id, season, home_team_id, away_team_id, kickoff,
  ext_source, ext_match_id, status, home_score, away_score, sport_id
)
SELECT
  lpm.league_id AS league_id,
  f.season::text AS season,
  th.id AS home_team_id,
  ta.id AS away_team_id,
  f.kickoff,
  'api_football' AS ext_source,
  f.fixture_id::text AS ext_match_id,

  CASE
    WHEN f.status IN ('NS','TBD') THEN 'SCHEDULED'
    WHEN f.status IN ('1H','2H','HT','LIVE') THEN 'LIVE'
    WHEN f.status IN ('FT','AET','PEN') THEN 'FINISHED'
    WHEN f.status = 'PST' THEN 'POSTPONED'
    WHEN f.status = 'CANC' THEN 'CANCELLED'
    ELSE 'SCHEDULED'
  END AS status,

  CASE WHEN f.status IN ('FT','AET','PEN') THEN f.home_goals ELSE NULL END AS home_score,
  CASE WHEN f.status IN ('FT','AET','PEN') THEN f.away_goals ELSE NULL END AS away_score,

  l.sport_id
FROM staging.api_football_fixtures f
JOIN public.league_provider_map lpm
  ON lpm.provider = 'api_football'
 AND lpm.provider_league_id = f.league_id::text
JOIN public.leagues l
  ON l.id = lpm.league_id
JOIN public.team_provider_map tph
  ON tph.provider = 'api_football'
 AND tph.provider_team_id = f.home_team_id::text
JOIN public.teams th
  ON th.id = tph.team_id
JOIN public.team_provider_map tpa
  ON tpa.provider = 'api_football'
 AND tpa.provider_team_id = f.away_team_id::text
JOIN public.teams ta
  ON ta.id = tpa.team_id
WHERE f.run_id = :run_id
ON CONFLICT (ext_source, ext_match_id) DO UPDATE
SET
  kickoff     = EXCLUDED.kickoff,
  status      = EXCLUDED.status,
  home_score  = EXCLUDED.home_score,
  away_score  = EXCLUDED.away_score,
  updated_at  = now();