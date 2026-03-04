CREATE OR REPLACE VIEW ml_block_candidates_latest_v1 AS
WITH m AS (
  SELECT *
  FROM ml_market_odds_latest_v1
),
s AS (
  SELECT
    kickoff,
    match_id,
    league_id,

    -- model pravděpodobnosti (česky: odhad výsledku)
    p_home, p_draw, p_away,

    -- "market" kurzy (česky: kurzy jako bookmaker/trh – zatím simulované)
    market_home, market_draw, market_away,

    LEAST(market_home, market_draw, market_away) AS min_odds,
    GREATEST(market_home, market_draw, market_away) AS max_odds,

    -- vyrovnanost: blízkost k 1/3, 1/3, 1/3 (česky: jak vyrovnaný zápas)
    (1.0
      - (abs(p_home - (1.0/3.0))
       + abs(p_draw - (1.0/3.0))
       + abs(p_away - (1.0/3.0)))
    ) AS balance_score
  FROM m
)
SELECT
  *,
  -- finální skóre pro blok: hlavně min_odds + trochu vyrovnanost
  (0.7 * ln(NULLIF(min_odds, 0.0)) + 0.3 * balance_score) AS block_score
FROM s;
