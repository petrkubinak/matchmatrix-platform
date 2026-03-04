WITH base AS (
  SELECT
    od.match_id,
    o.code AS outcome,
    od.odd_value,
    1.0 / od.odd_value AS inv
  FROM odds od
  JOIN market_outcomes o ON o.id = od.market_outcome_id
  JOIN markets m ON m.id = o.market_id
  JOIN bookmakers b ON b.id = od.bookmaker_id
  WHERE m.code = '1X2'
    AND b.name = 'Manual'
    AND od.match_id IN (1,2)
),
norm AS (
  SELECT match_id, SUM(inv) AS inv_sum
  FROM base
  GROUP BY match_id
)
SELECT
  b.match_id,
  b.outcome,
  b.odd_value,
  ROUND((b.inv / n.inv_sum)::numeric, 6) AS p_norm
FROM base b
JOIN norm n ON n.match_id = b.match_id
ORDER BY b.match_id, b.outcome;
