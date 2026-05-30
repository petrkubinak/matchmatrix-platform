/*
MATCHMATRIX SQL 108_I
Operations Center Summary V1.1
*/

CREATE OR REPLACE VIEW ops.v_operations_center_summary_v1 AS
SELECT
    s.scheduler_state,
    s.scheduler_color,

    p.pending_jobs,
    p.failed_jobs,
    p.retry_risk_jobs,
    p.planner_state,
    p.planner_color,

    s.safe_autonomous_workers,
    s.runnable_workers,
    ROUND(s.avg_confidence_score, 2) AS avg_confidence_score,

    COUNT(a.*) AS alert_groups,

    COUNT(a.*) FILTER (
        WHERE a.alert_severity = 'CRITICAL'
          AND a.last_alert_time >= now() - interval '24 hours'
    ) AS critical_alert_groups_24h,

    COUNT(a.*) FILTER (
        WHERE a.alert_severity = 'WARNING'
          AND a.last_alert_time >= now() - interval '24 hours'
    ) AS warning_alert_groups_24h,

    CASE
        WHEN COUNT(a.*) FILTER (
            WHERE a.alert_severity = 'CRITICAL'
              AND a.last_alert_time >= now() - interval '24 hours'
        ) > 0
            THEN 'CRITICAL'

        WHEN COUNT(a.*) FILTER (
            WHERE a.alert_severity = 'WARNING'
              AND a.last_alert_time >= now() - interval '24 hours'
        ) > 0
            THEN 'WARNING'

        WHEN p.planner_state = 'BUSY'
            THEN 'BUSY'

        WHEN s.scheduler_state = 'READY'
            THEN 'READY'

        ELSE 'CHECK'
    END AS operations_state,

    CASE
        WHEN COUNT(a.*) FILTER (
            WHERE a.alert_severity = 'CRITICAL'
              AND a.last_alert_time >= now() - interval '24 hours'
        ) > 0
            THEN 'RED'

        WHEN COUNT(a.*) FILTER (
            WHERE a.alert_severity = 'WARNING'
              AND a.last_alert_time >= now() - interval '24 hours'
        ) > 0
            THEN 'YELLOW'

        WHEN p.planner_state = 'BUSY'
            THEN 'YELLOW'

        WHEN s.scheduler_state = 'READY'
            THEN 'GREEN'

        ELSE 'PURPLE'
    END AS operations_color

FROM ops.v_scheduler_queue_summary_v1 s
CROSS JOIN ops.v_planner_queue_summary_v1 p
LEFT JOIN ops.v_runtime_alerts_grouped_v1 a
    ON true

GROUP BY
    s.scheduler_state,
    s.scheduler_color,
    p.pending_jobs,
    p.failed_jobs,
    p.retry_risk_jobs,
    p.planner_state,
    p.planner_color,
    s.safe_autonomous_workers,
    s.runnable_workers,
    s.avg_confidence_score;