-- =========================================================
-- 187_preview_hk_top_runnable_jobs.sql
-- MATCHMATRIX - preview HK TOP runnable jobs
-- =========================================================

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