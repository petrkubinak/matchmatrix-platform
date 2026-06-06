CREATE OR REPLACE VIEW ops.v_smart_core_quota_queue_v1 AS
SELECT
    ip.sport_code,
    sip.sport_name,
    ip.entity,
    ip.run_group,
    ip.status,
    sip.mode,
    sip.daily_request_budget,
    sip.priority AS sport_priority,
    COUNT(*) AS pending_count,
    MIN(ip.id) AS first_planner_id,
    MAX(ip.created_at) AS newest_created_at
FROM ops.ingest_planner ip
JOIN ops.sports_import_plan sip
    ON LOWER(sip.sport_code) = LOWER(ip.sport_code)
WHERE ip.status = 'pending'
  AND sip.enabled = TRUE
  AND sip.mode = 'historical_backfill'
  AND ip.entity IN ('fixtures', 'teams', 'leagues')
GROUP BY
    ip.sport_code,
    sip.sport_name,
    ip.entity,
    ip.run_group,
    ip.status,
    sip.mode,
    sip.daily_request_budget,
    sip.priority
ORDER BY
    sip.daily_request_budget DESC,
    sip.priority DESC,
    pending_count DESC;