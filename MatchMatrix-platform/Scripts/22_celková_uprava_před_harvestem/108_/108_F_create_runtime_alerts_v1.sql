/*
MATCHMATRIX SQL 108_F
Runtime Alerts Engine V1

CO TO JE:
- Central runtime alert engine.
- Generuje orchestration alerty.

K ČEMU TO JE:
- Panel V17.6 dostane:
  - runtime warnings
  - planner overload
  - stale heartbeat
  - retry pressure
  - unstable workers
  - failed pipelines

KDE TO UVIDÍME:
- ops.v_runtime_alerts_v1
- Runtime Alerts widget
- Scheduler Health Bar

JAK SE TO VYUŽIJE:
- autonomous orchestration
- scheduler diagnostics
- runtime governance
- retry governance
- self-healing scheduler
*/

CREATE OR REPLACE VIEW ops.v_runtime_alerts_v1 AS

/* =========================================================
   FAILED WORKERS
========================================================= */
SELECT
    'FAILED_WORKER' AS alert_type,

    rf.job_code AS source_object,

    rf.failure_category AS alert_category,

    CASE
        WHEN rf.failure_state = 'FAILED'
            THEN 'CRITICAL'
        ELSE 'WARNING'
    END AS alert_severity,

    CASE
        WHEN rf.failure_state = 'FAILED'
            THEN 'RED'
        ELSE 'YELLOW'
    END AS alert_color,

    CONCAT(
        'Worker ',
        rf.job_code,
        ' status=',
        rf.status,
        ' category=',
        rf.failure_category
    ) AS alert_message,

    rf.started_at AS alert_time

FROM ops.v_recent_failures_v1 rf
WHERE rf.job_code NOT IN (
    'ingest_fixtures'
)

UNION ALL

/* =========================================================
   PLANNER OVERLOAD
========================================================= */
SELECT
    'PLANNER_OVERLOAD' AS alert_type,

    'ingest_planner' AS source_object,

    'PLANNER' AS alert_category,

    CASE
        WHEN pending_jobs > 10000
            THEN 'CRITICAL'
        WHEN pending_jobs > 3000
            THEN 'WARNING'
        ELSE 'INFO'
    END AS alert_severity,

    CASE
        WHEN pending_jobs > 10000
            THEN 'RED'
        WHEN pending_jobs > 3000
            THEN 'YELLOW'
        ELSE 'PURPLE'
    END AS alert_color,

    CONCAT(
        'Planner pending jobs: ',
        pending_jobs
    ) AS alert_message,

    now() AS alert_time

FROM ops.v_planner_queue_summary_v1

UNION ALL

/* =========================================================
   RETRY PRESSURE
========================================================= */
SELECT
    'RETRY_PRESSURE' AS alert_type,

    worker_code AS source_object,

    'RETRY' AS alert_category,

    CASE
        WHEN retry_risk = 'HIGH'
            THEN 'CRITICAL'
        WHEN retry_risk = 'MEDIUM'
            THEN 'WARNING'
        ELSE 'INFO'
    END AS alert_severity,

    CASE
        WHEN retry_risk = 'HIGH'
            THEN 'RED'
        WHEN retry_risk = 'MEDIUM'
            THEN 'YELLOW'
        ELSE 'PURPLE'
    END AS alert_color,

    CONCAT(
        'Retry risk=',
        retry_risk,
        ' health=',
        scheduler_health_tier
    ) AS alert_message,

    last_started_at AS alert_time

FROM ops.v_scheduler_runtime_dashboard_v1

WHERE retry_risk <> 'NONE'

UNION ALL

/* =========================================================
   STALE HEARTBEAT
========================================================= */
SELECT
    'STALE_HEARTBEAT' AS alert_type,

    lock_name AS source_object,

    'HEARTBEAT' AS alert_category,

    'WARNING' AS alert_severity,

    'YELLOW' AS alert_color,

    CONCAT(
        'Heartbeat stale for ',
        heartbeat_age_seconds,
        ' seconds'
    ) AS alert_message,

    heartbeat_at AS alert_time

FROM ops.v_active_runs_live_v1

WHERE live_state = 'ACTIVE_STALE_HEARTBEAT'

UNION ALL

/* =========================================================
   BLOCKED WORKERS
========================================================= */
SELECT
    'BLOCKED_WORKER' AS alert_type,

    worker_code AS source_object,

    'SCHEDULER' AS alert_category,

    'CRITICAL' AS alert_severity,

    'RED' AS alert_color,

    CONCAT(
        'Execution blocked: ',
        execution_decision
    ) AS alert_message,

    last_started_at AS alert_time

FROM ops.v_scheduler_runtime_dashboard_v1

WHERE execution_decision IN (
    'BLOCK',
    'BLOCK_TEMPORARY'
)

ORDER BY alert_time DESC NULLS LAST;