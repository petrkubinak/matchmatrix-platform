UPDATE ops.ingest_planner
SET
    status = 'pending',
    updated_at = now()
WHERE id IN (5845, 5846, 5847);

SELECT id, provider, sport_code, entity, status, attempts
FROM ops.ingest_planner
WHERE id IN (5845, 5846, 5847)
ORDER BY id;