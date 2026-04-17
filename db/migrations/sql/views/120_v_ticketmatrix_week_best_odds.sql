CREATE OR REPLACE VIEW public.v_ticketmatrix_week_best_odds AS
WITH week_matches AS (
  SELECT
    m.match_id,
    m.home_team_name,
    m.away_team_name,
    m.league_name,
    m.kickoff_at_local
  FROM public.v_fd_matches_base m
  WHERE m.kickoff_at_local >= date_trunc('day', (now() AT TIME ZONE 'Europe/Prague'))
    AND m.kickoff_at_local <  date_trunc('day', (now() AT TIME ZONE 'Europe/Prague')) + interval '7 day'
),
best_1 AS (
  SELECT match_id, MAX(odd_value) AS odds_1
  FROM public.odds
  WHERE market_outcome_id = 1
  GROUP BY match_id
),
best_2 AS (
  SELECT match_id, MAX(odd_value) AS odds_2
  FROM public.odds
  WHERE market_outcome_id = 2
  GROUP BY match_id
),
best_x AS (
  SELECT match_id, MAX(odd_value) AS odds_x
  FROM public.odds
  WHERE market_outcome_id = 3
  GROUP BY match_id
)
SELECT
  w.match_id,
  w.home_team_name,
  w.away_team_name,
  w.league_name,
  w.kickoff_at_local,
  b1.odds_1,
  bx.odds_x,
  b2.odds_2
FROM week_matches w
LEFT JOIN best_1 b1 ON b1.match_id = w.match_id
LEFT JOIN best_x bx ON bx.match_id = w.match_id
LEFT JOIN best_2 b2 ON b2.match_id = w.match_id
ORDER BY w.kickoff_at_local ASC, w.league_name ASC;