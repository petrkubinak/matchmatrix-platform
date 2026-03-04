SELECT
  run_id,
  ROUND(SUM(probability)::numeric, 6) AS run_probability_sum,
  MIN(probability) AS min_ticket_p,
  MAX(probability) AS max_ticket_p
FROM generated_tickets
WHERE run_id = 3
GROUP BY run_id;

