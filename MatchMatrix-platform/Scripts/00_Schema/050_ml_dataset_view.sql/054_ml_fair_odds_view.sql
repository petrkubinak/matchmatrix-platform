CREATE OR REPLACE VIEW ml_fair_odds_latest_v1 AS
WITH latest_run AS (
  SELECT model_code, max(run_ts) AS run_ts
  FROM ml_predictions
  GROUP BY model_code
),
p AS (
  SELECT mp.*
  FROM ml_predictions mp
  JOIN latest_run lr
    ON lr.model_code = mp.model_code
   AND lr.run_ts = mp.run_ts
)
SELECT
  p.model_code,
  p.run_ts,
  p.match_id,
  p.league_id,
  p.kickoff,
  p.p_away,
  p.p_draw,
  p.p_home,
  CASE WHEN p.p_away > 0 THEN round((1.0 / p.p_away)::numeric, 3) ELSE NULL END AS fair_away,
  CASE WHEN p.p_draw > 0 THEN round((1.0 / p.p_draw)::numeric, 3) ELSE NULL END AS fair_draw,
  CASE WHEN p.p_home > 0 THEN round((1.0 / p.p_home)::numeric, 3) ELSE NULL END AS fair_home
FROM p;
