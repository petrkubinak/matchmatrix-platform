SELECT
  ticket_index,
  snapshot
FROM generated_tickets
WHERE run_id = 1
ORDER BY ticket_index;
