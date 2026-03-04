-- 094_run_job_finish.sql

-- Parametry:
-- :run_id
-- :final_status
-- :message

UPDATE ops.job_runs
SET
    finished_at = NOW(),
    status = :final_status,
    message = :message,
    updated_at = NOW()
WHERE id = :run_id;