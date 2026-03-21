CREATE OR REPLACE VIEW ops.v_ops_hk_core_full_job_catalog AS
SELECT
    t.provider,
    t.sport_code,
    t.run_group,
    ep.entity,
    ep.priority AS entity_order,
    COUNT(*) AS target_count,
    COUNT(*) AS planned_requests,
    t.provider || '__' || t.run_group || '__' || ep.entity AS job_code
FROM ops.ingest_targets t
JOIN ops.ingest_entity_plan ep
  ON ep.provider = t.provider
 AND ep.sport_code = t.sport_code
WHERE t.provider = 'api_hockey'
  AND t.sport_code = 'HK'
  AND t.run_group = 'HK_CORE'
  AND t.enabled = true
  AND ep.enabled = true
GROUP BY
    t.provider,
    t.sport_code,
    t.run_group,
    ep.entity,
    ep.priority
ORDER BY
    ep.priority,
    ep.entity;