SELECT
    id,
    job_code,
    started_at,
    finished_at,
    status,
    message,
    rows_affected
FROM ops.job_runs
WHERE job_code = 'unified_ingest_batch'
ORDER BY id DESC
LIMIT 20;