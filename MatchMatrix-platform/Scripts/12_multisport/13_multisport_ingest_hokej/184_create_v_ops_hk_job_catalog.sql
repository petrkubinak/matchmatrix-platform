-- =========================================================
-- 184_create_v_ops_hk_job_catalog.sql
-- MATCHMATRIX - HK job catalog
-- =========================================================

CREATE OR REPLACE VIEW ops.v_ops_hk_job_catalog AS
SELECT
    'HK_TOP'::text AS layer,
    1 AS layer_order,
    provider,
    sport_code,
    entity,
    entity_order,
    run_group,
    COUNT(*) AS target_count,
    COUNT(*) AS planned_requests,
    MIN(NULLIF(season, '')) AS min_effective_season,
    MAX(NULLIF(season, '')) AS max_effective_season,
    provider || '__' || run_group || '__' || entity AS job_code
FROM ops.v_ops_hk_top_test_execution_order
GROUP BY
    provider,
    sport_code,
    entity,
    entity_order,
    run_group
ORDER BY
    layer_order,
    entity_order,
    provider,
    entity;

-- kontrola
SELECT
    layer,
    layer_order,
    provider,
    sport_code,
    entity,
    entity_order,
    run_group,
    target_count,
    planned_requests,
    job_code
FROM ops.v_ops_hk_job_catalog
ORDER BY
    layer_order,
    entity_order,
    provider,
    entity;