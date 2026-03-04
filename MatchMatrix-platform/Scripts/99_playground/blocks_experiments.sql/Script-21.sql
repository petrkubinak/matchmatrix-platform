UPDATE generated_runs r
SET run_probability = s.p
FROM (
  SELECT run_id, ROUND(SUM(probability)::numeric, 6) AS p
  FROM generated_tickets
  WHERE run_id = 3
  GROUP BY run_id
) s
WHERE r.id = s.run_id;
