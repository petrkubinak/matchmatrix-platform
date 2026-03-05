CREATE OR REPLACE VIEW public.v_leagues_active_week AS
SELECT
  league_id,
  league_name,
  sport_code,
  COUNT(*) AS matches_in_week,
  MIN(kickoff_at_local) AS first_kickoff_local,
  MAX(kickoff_at_local) AS last_kickoff_local
FROM public.v_matches_week
GROUP BY league_id, league_name, sport_code
ORDER BY matches_in_week DESC, league_name ASC;