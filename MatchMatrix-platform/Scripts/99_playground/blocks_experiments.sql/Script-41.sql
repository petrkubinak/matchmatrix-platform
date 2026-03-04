SELECT
  run_id,
  ROUND(SUM(probability)::numeric, 6) AS run_probability_sum
FROM generated_tickets
WHERE run_id = 4
GROUP BY run_id;
