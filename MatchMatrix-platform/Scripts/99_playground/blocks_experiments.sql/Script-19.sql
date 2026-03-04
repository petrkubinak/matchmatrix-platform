SELECT ticket_index, probability, snapshot
FROM generated_tickets
WHERE run_id = 3
ORDER BY ticket_index;
