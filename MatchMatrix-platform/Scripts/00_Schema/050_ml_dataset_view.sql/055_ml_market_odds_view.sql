CREATE OR REPLACE VIEW ml_market_odds_latest_v1 AS
WITH latest_run AS (
  SELECT model_code, max(run_ts) AS run_ts
  FROM ml_predictions
  GROUP BY model_code
),
p0 AS (
  SELECT mp.*
  FROM ml_predictions mp
  JOIN latest_run lr
    ON lr.model_code = mp.model_code
   AND lr.run_ts = mp.run_ts
),
-- params
params AS (
  SELECT
    0.55::double precision AS temp,   -- T < 1 = ostřejší rozdíly
    0.04::double precision AS margin  -- 4% marže
),
-- sharpen: p^(1/T) + normalize
sharp AS (
  SELECT
    p0.*,
    params.temp,
    params.margin,

    power(greatest(p0.p_away, 1e-9), 1.0 / params.temp) AS s_away,
    power(greatest(p0.p_draw, 1e-9), 1.0 / params.temp) AS s_draw,
    power(greatest(p0.p_home, 1e-9), 1.0 / params.temp) AS s_home
  FROM p0, params
),
norm AS (
  SELECT
    *,
    (s_away + s_draw + s_home) AS s_sum
  FROM sharp
),
p AS (
  SELECT
    model_code, run_ts, match_id, league_id, kickoff,
    p_away, p_draw, p_home,
    (s_away / s_sum) AS p_away_sharp,
    (s_draw / s_sum) AS p_draw_sharp,
    (s_home / s_sum) AS p_home_sharp,
    margin
  FROM norm
)
SELECT
  model_code,
  run_ts,
  match_id,
  league_id,
  kickoff,

  p_away, p_draw, p_home,
  p_away_sharp, p_draw_sharp, p_home_sharp,

  -- fair odds (sharpened)
  round((1.0 / p_away_sharp)::numeric, 3) AS fair_away_sharp,
  round((1.0 / p_draw_sharp)::numeric, 3) AS fair_draw_sharp,
  round((1.0 / p_home_sharp)::numeric, 3) AS fair_home_sharp,

  -- market odds (add margin)
  round((1.0 / (p_away_sharp * (1.0 + margin)))::numeric, 3) AS market_away,
  round((1.0 / (p_draw_sharp * (1.0 + margin)))::numeric, 3) AS market_draw,
  round((1.0 / (p_home_sharp * (1.0 + margin)))::numeric, 3) AS market_home

FROM p;
