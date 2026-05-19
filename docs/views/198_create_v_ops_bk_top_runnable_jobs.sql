CREATE OR REPLACE VIEW ops.v_ops_bk_top_runnable_jobs AS
SELECT
    c.provider,
    c.sport_code,
    c.run_group,
    c.entity,
    c.entity_order,
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
FROM ops.v_ops_bk_top_full_job_catalog c
JOIN ops.provider_jobs pj
  ON pj.provider = c.provider
 AND pj.sport_code = c.sport_code
 AND pj.job_code = c.job_code
WHERE pj.enabled = true
ORDER BY pj.priority, c.entity_order, c.entity;