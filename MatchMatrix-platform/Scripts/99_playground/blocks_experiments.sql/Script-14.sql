SELECT run_id, COUNT(*) AS tickets
FROM generated_tickets
WHERE run_id = 3
GROUP BY run_id;
