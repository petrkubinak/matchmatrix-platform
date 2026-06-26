UPDATE ops.ingest_planner
SET
    status='pending',
    attempts=0,
    next_run=now()
WHERE id=8821;