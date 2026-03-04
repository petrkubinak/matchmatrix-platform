INSERT INTO odds (match_id, bookmaker_id, market_outcome_id, odd_value)
SELECT
  3,
  b.id,
  o.id,
  x.odd
FROM bookmakers b
JOIN market_outcomes o ON o.code IN ('1','X','2')
JOIN markets mk ON mk.id = o.market_id AND mk.code = '1X2'
JOIN (VALUES
  ('1', 2.40),
  ('X', 3.30),
  ('2', 2.80)
) AS x(code, odd) ON x.code = o.code
WHERE b.name = 'Manual';
