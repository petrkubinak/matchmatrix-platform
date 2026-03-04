-- 093_run_job_create.sql
-- Vytvoření nového job run (safe quoting)

-- Parametry:
-- :job_code      (text)
-- :params_json   (json / NULL)

WITH job_row AS (
    SELECT default_params
    FROM ops.jobs
    WHERE code = :'job_code'
      AND enabled = true
)
INSERT INTO ops.job_runs (
    job_code,
    started_at,
    status,
    params,
    created_at
)
SELECT
    :'job_code',
    NOW(),
    'running',
    COALESCE(NULLIF(:params_json, '')::jsonb, job_row.default_params),
    NOW()
FROM job_row
RETURNING id;