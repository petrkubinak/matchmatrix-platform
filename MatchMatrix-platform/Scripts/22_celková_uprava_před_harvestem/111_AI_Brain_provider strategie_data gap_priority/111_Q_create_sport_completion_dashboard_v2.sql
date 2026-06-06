CREATE OR REPLACE VIEW ops.v_sport_completion_dashboard_v1 AS
WITH sports AS (
    SELECT
        sport_code,
        sport_name,
        priority,
        mode,
        daily_request_budget
    FROM ops.sports_import_plan
    WHERE enabled = TRUE
),
completion AS (
    SELECT
        CASE
            WHEN sport_code = 'FB' THEN 'football'
            WHEN sport_code = 'HK' THEN 'hockey'
            WHEN sport_code = 'BK' THEN 'basketball'
            WHEN sport_code = 'HB' THEN 'handball'
            WHEN sport_code = 'VB' THEN 'volleyball'
            WHEN sport_code = 'BSB' THEN 'baseball'
            WHEN sport_code = 'AFB' THEN 'american_football'
            WHEN sport_code = 'CK' THEN 'cricket'
            WHEN sport_code = 'RGB' THEN 'rugby'
            WHEN sport_code = 'TN' THEN 'tennis'
            WHEN sport_code = 'MMA' THEN 'mma'
            WHEN sport_code = 'ESP' THEN 'esports'
            WHEN sport_code = 'FH' THEN 'field_hockey'
            WHEN sport_code = 'DRT' THEN 'darts'
            ELSE LOWER(sport_code)
        END AS sport_code,
        entity_count,
        ready_cnt,
        near_ready_cnt,
        not_ready_cnt,
        core_ready_cnt,
        people_ready_cnt,
        people_near_ready_cnt,
        people_not_ready_cnt,
        sport_readiness,
        top_priority_rank
    FROM ops.v_sport_completion_summary
),
coverage AS (
    SELECT
        CASE
            WHEN sport_code = 'FB' THEN 'football'
            WHEN sport_code = 'HK' THEN 'hockey'
            WHEN sport_code = 'BK' THEN 'basketball'
            WHEN sport_code = 'HB' THEN 'handball'
            WHEN sport_code = 'VB' THEN 'volleyball'
            WHEN sport_code = 'BSB' THEN 'baseball'
            WHEN sport_code = 'AFB' THEN 'american_football'
            WHEN sport_code = 'CK' THEN 'cricket'
            WHEN sport_code = 'RGB' THEN 'rugby'
            WHEN sport_code = 'TN' THEN 'tennis'
            WHEN sport_code = 'MMA' THEN 'mma'
            WHEN sport_code = 'ESP' THEN 'esports'
            WHEN sport_code = 'FH' THEN 'field_hockey'
            WHEN sport_code = 'DRT' THEN 'darts'
            ELSE LOWER(sport_code)
        END AS sport_code,
        SUM(CASE WHEN gap_status_code = 'READY' THEN item_count ELSE 0 END) AS ready_count,
        SUM(item_count) AS total_count
    FROM ops.v_coverage_progress_by_sport_v1
    GROUP BY 1
),
budget AS (
    SELECT
        LOWER(sport_code) AS sport_code,
        requests_used,
        requests_limit,
        requests_remaining,
        used_pct,
        budget_status
    FROM ops.v_sport_daily_budget_monitor_v1
),
pending_core AS (
    SELECT
        LOWER(sport_code) AS sport_code,
        SUM(pending_count) AS core_pending
    FROM ops.v_smart_core_quota_queue_v1
    GROUP BY LOWER(sport_code)
)
SELECT
    s.sport_code,
    s.sport_name,
    s.mode,

    ROUND(
        CASE WHEN COALESCE(c.entity_count, 0) > 0
             THEN COALESCE(c.core_ready_cnt, 0)::numeric / c.entity_count::numeric * 100
             ELSE 0
        END, 2
    ) AS core_pct,

    ROUND(
        CASE WHEN COALESCE(c.entity_count, 0) > 0
             THEN COALESCE(c.people_ready_cnt, 0)::numeric / c.entity_count::numeric * 100
             ELSE 0
        END, 2
    ) AS people_pct,

    0.00::numeric AS media_pct,
    0.00::numeric AS odds_pct,

    ROUND(
        CASE WHEN COALESCE(cov.total_count, 0) > 0
             THEN cov.ready_count::numeric / cov.total_count::numeric * 100
             ELSE 0
        END, 2
    ) AS total_pct,

    COALESCE(pc.core_pending, 0) AS core_pending,
    COALESCE(b.requests_used, 0) AS requests_used,
    COALESCE(b.requests_limit, 0) AS requests_limit,
    COALESCE(b.requests_remaining, 0) AS requests_remaining,
    COALESCE(b.used_pct, 0) AS budget_used_pct,
    COALESCE(b.budget_status, 'UNKNOWN') AS budget_status,

    COALESCE(c.sport_readiness, 'UNKNOWN') AS sport_readiness,
    COALESCE(c.top_priority_rank, 999) AS top_priority_rank,

    CASE
        WHEN COALESCE(pc.core_pending, 0) > 0 THEN 'CORE_HARVEST'
        WHEN COALESCE(c.people_not_ready_cnt, 0) > 0 THEN 'PEOPLE_LAYER'
        WHEN COALESCE(cov.total_count, 0) > 0
             AND COALESCE(cov.ready_count, 0) < COALESCE(cov.total_count, 0) THEN 'DATA_GAP'
        ELSE 'MONITOR'
    END AS recommended_focus

FROM sports s
LEFT JOIN completion c ON c.sport_code = s.sport_code
LEFT JOIN coverage cov ON cov.sport_code = s.sport_code
LEFT JOIN budget b ON b.sport_code = s.sport_code
LEFT JOIN pending_core pc ON pc.sport_code = s.sport_code
ORDER BY
    total_pct ASC,
    core_pending DESC,
    s.priority DESC;