CREATE OR REPLACE VIEW public.v_fd_matches_week AS
SELECT
  match_id,
  league_id,
  league_name,
  sport_code,
  season,
  kickoff_at_utc,
  kickoff_at_local,
  status,
  home_team_id,
  home_team_name,
  away_team_id,
  away_team_name
FROM public.v_fd_matches_base
WHERE
  kickoff_at_local >= (date_trunc('day', now() AT TIME ZONE 'Europe/Prague') AT TIME ZONE 'Europe/Prague')
  AND kickoff_at_local <  ((date_trunc('day', now() AT TIME ZONE 'Europe/Prague') AT TIME ZONE 'Europe/Prague') + interval '7 days');