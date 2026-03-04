CREATE OR REPLACE VIEW ml_value_ev_latest_v1 AS
WITH v AS (
  SELECT *
  FROM ml_value_latest_v1
)
SELECT
  kickoff,
  match_id,

  p_home, p_draw, p_away,
  market_home, market_draw, market_away,

  edge_home, edge_draw, edge_away,

  -- Expected value (ROI per 1 unit stake)
  (p_home * market_home - 1.0) AS ev_home,
  (p_draw * market_draw - 1.0) AS ev_draw,
  (p_away * market_away - 1.0) AS ev_away,

  -- Kelly fraction (full Kelly). Clamp na >= 0.
  -- Kelly pro decimal odds: f* = (p*odds - 1)/(odds - 1)
  GREATEST(0.0, (p_home * market_home - 1.0) / NULLIF(market_home - 1.0, 0.0)) AS kelly_home,
  GREATEST(0.0, (p_draw * market_draw - 1.0) / NULLIF(market_draw - 1.0, 0.0)) AS kelly_draw,
  GREATEST(0.0, (p_away * market_away - 1.0) / NULLIF(market_away - 1.0, 0.0)) AS kelly_away

FROM v;
