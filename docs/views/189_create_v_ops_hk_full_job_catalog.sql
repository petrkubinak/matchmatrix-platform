CREATE OR REPLACE VIEW ops.v_ops_hk_full_job_catalog AS
SELECT
    provider,
    sport_code,
    run_group,
    entity,
    entity_order,
    COUNT(*) AS target_count,
    COUNT(*) AS planned_requests,
    provider || '__' || run_group || '__' || entity AS job_code
FROM ops.v_ops_hk_top_full_execution_order
GROUP BY
    provider,
    sport_code,
    run_group,
    entity,
    entity_order
ORDER BY
    entity_order,
    entity;