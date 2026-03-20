-- =========================================================
-- 186_create_v_ops_hk_top_runnable_jobs.sql
-- MATCHMATRIX - HK TOP runnable jobs
-- =========================================================

CREATE OR REPLACE VIEW ops.v_ops_hk_top_runnable_jobs AS
SELECT
    c.layer,
    c.layer_order,
    c.provider,
    c.sport_code,
    c.entity,
    c.entity_order,
    c.run_group,
    c.target_count,
    c.planned_requests,
    c.job_code,
    pj.ingest_mode,
    pj.enabled,
    pj.priority,
    pj.batch_size,
    pj.max_requests_per_run,
    pj.retry_limit,
    pj.cooldown_seconds,
    pj.days_back,
    pj.days_forward
FROM ops.v_ops_hk_job_catalog c
JOIN ops.provider_jobs pj
  ON pj.provider = c.provider
 AND pj.sport_code = c.sport_code
 AND pj.job_code = c.job_code
WHERE pj.enabled = true
ORDER BY
    c.layer_order,
    c.entity_order,
    pj.priority,
    c.job_code;

-- kontrola
SELECT
    provider,
    sport_code,
    entity,
    job_code,
    ingest_mode,
    priority,
    planned_requests
FROM ops.v_ops_hk_top_runnable_jobs
ORDER BY
    layer_order,
    entity_order,
    priority,
    job_code;