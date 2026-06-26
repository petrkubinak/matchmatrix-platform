/*
MATCHMATRIX SQL 108_G
Runtime Operations Center Feed V1

CO TO JE:
- Centrální feed orchestration runtime systému.
- Jeden unified feed pro panel V17.6.

SPOJUJE:
- runtime alerts
- planner summary
- scheduler summary
- active runs
- orchestration runtime

K ČEMU TO JE:
- Panel už nebude dělat 10 dotazů.
- V17.6 bude mít jeden operations feed.

KDE TO UVIDÍME:
- ops.v_runtime_operations_center_feed_v1
- Runtime Operations Center

JAK SE TO VYUŽIJE:
- live monitoring
- orchestration dashboard
- scheduler operations center
- autonomous governance
*/

CREATE OR REPLACE VIEW ops.v_runtime_operations_center_feed_v1 AS

/* =========================================================
   ALERTS
========================================================= */
SELECT
    'ALERT' AS feed_type,

    alert_type AS object_type,
    source_object AS object_name,

    alert_severity AS severity,
    alert_color AS color,

    alert_message AS message,

    alert_time AS event_time

FROM ops.v_runtime_alerts_v1

UNION ALL

/* =========================================================
   ACTIVE RUNS
========================================================= */
SELECT
    'ACTIVE_RUN' AS feed_type,

    'LOCK' AS object_type,
    lock_name AS object_name,

    live_state AS severity,
    live_color AS color,

    CONCAT(
        'Running ',
        running_seconds,
        ' sec | heartbeat age ',
        heartbeat_age_seconds,
        ' sec'
    ) AS message,

    acquired_at AS event_time

FROM ops.v_active_runs_live_v1

UNION ALL

/* =========================================================
   PLANNER SUMMARY
========================================================= */
SELECT
    'PLANNER' AS feed_type,

    'QUEUE' AS object_type,
    'ingest_planner' AS object_name,

    planner_state AS severity,
    planner_color AS color,

    CONCAT(
        'Pending=',
        pending_jobs,
        ' Done=',
        done_jobs,
        ' Failed=',
        failed_jobs
    ) AS message,

    last_job_update_at AS event_time

FROM ops.v_planner_queue_summary_v1

UNION ALL

/* =========================================================
   SCHEDULER SUMMARY
========================================================= */
SELECT
    'SCHEDULER' AS feed_type,

    'QUEUE' AS object_type,
    'runtime_scheduler' AS object_name,

    scheduler_state AS severity,
    scheduler_color AS color,

    CONCAT(
        'Runnable=',
        runnable_workers,
        ' Safe=',
        safe_autonomous_workers,
        ' Avg confidence=',
        ROUND(avg_confidence_score, 2)
    ) AS message,

    now() AS event_time

FROM ops.v_scheduler_queue_summary_v1

ORDER BY event_time DESC NULLS LAST;