CREATE OR REPLACE VIEW ml_value_latest_v1 AS
WITH m AS (
    SELECT *
    FROM ml_market_odds_latest_v1
)
SELECT
    kickoff,
    match_id,

    p_home,
    p_draw,
    p_away,

    market_home,
    market_draw,
    market_away,

    (p_home - (1.0 / market_home)) AS edge_home,
    (p_draw - (1.0 / market_draw)) AS edge_draw,
    (p_away - (1.0 / market_away)) AS edge_away

FROM m;
