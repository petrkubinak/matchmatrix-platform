SELECT ticket_index, probability, snapshot
FROM generated_tickets
WHERE run_id = 4
ORDER BY ticket_index;
