CREATE OR REPLACE VIEW ops.v_api_budget_today AS
SELECT
    s.id AS sport_plan_id,
    s.sport_code,
    s.sport_name,
    s.enabled,
    s.priority,
    s.mode,
    s.provider,
    s.daily_request_budget,
    s.max_parallel_jobs,
    b.request_day,
    COALESCE(b.requests_used, 0) AS requests_used,
    COALESCE(b.requests_limit, s.daily_request_budget) AS requests_limit,
    COALESCE(b.requests_remaining, s.daily_request_budget) AS requests_remaining,
    b.last_updated
FROM ops.sports_import_plan s
LEFT JOIN ops.api_budget_status b
    ON b.sport_code = s.sport_code
   AND b.request_day = CURRENT_DATE
WHERE s.enabled = true
ORDER BY s.priority, s.sport_code;