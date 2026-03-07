SELECT
    o.match_id,
    o.odd_value AS open_odds,
    c.close_odd,
    (o.odd_value / c.close_odd) - 1 AS clv
FROM odds o
JOIN closing_odds c
  ON c.match_id = o.match_id
 AND c.market_outcome_id = o.market_outcome_id;