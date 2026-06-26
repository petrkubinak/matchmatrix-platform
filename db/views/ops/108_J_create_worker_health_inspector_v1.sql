/*
MATCHMATRIX SQL 108_J
Create Worker Health Inspector V1

CO TO JE:
- View pro detailní kontrolu zdraví workerů.

K ČEMU TO JE:
- Aby panel ukázal, který worker je OK, který má warning a který padá.

KDE TO UVIDÍME:
- ops.v_worker_health_inspector_v1
- následně panel V17.8

JAK SE TO VYUŽIJE:
- worker audit
- failed worker inspection
- retry governance
- self-healing orchestration
*/

CREATE OR REPLACE VIEW ops.v_worker_health_inspector_v1 AS
WITH dashboard AS (
    SELECT
        worker_code,
        execution_decision,
        execution_confidence_score,
        scheduler_health_tier,
        recent_health_tier,
        dashboard_state
    FROM ops.v_scheduler_runtime_dashboard_v1
),
history_24h AS (
    SELECT
        worker_name,
        COUNT(*) AS runs_24h,
        COUNT(*) FILTER (
            WHERE LOWER(status) IN ('error', 'failed', 'fail', 'warning')
        ) AS failures_24h,
        ROUND(AVG(duration_sec), 2) AS avg_duration_sec,
        MAX(created_at) AS last_run_at,
        (ARRAY_AGG(status ORDER BY created_at DESC))[1] AS last_status,
        (ARRAY_AGG(
            COALESCE(NULLIF(stderr_preview, ''), NULLIF(stdout_preview, ''), '')
            ORDER BY created_at DESC
        ))[1] AS last_message
    FROM ops.runtime_execution_history
    WHERE created_at >= NOW() - INTERVAL '24 hours'
    GROUP BY worker_name
),
active_runs AS (
    SELECT
        worker_name,
        execution_state,
        pid,
        started_at,
        last_heartbeat,
        EXTRACT(EPOCH FROM (NOW() - last_heartbeat))::int AS heartbeat_age_sec
    FROM ops.active_worker_runs
)
SELECT
    COALESCE(d.worker_code, h.worker_name, a.worker_name) AS worker_name,

    d.execution_decision,
    d.execution_confidence_score,
    d.scheduler_health_tier,
    d.recent_health_tier,
    d.dashboard_state,

    COALESCE(h.runs_24h, 0) AS runs_24h,
    COALESCE(h.failures_24h, 0) AS failures_24h,
    h.avg_duration_sec,
    h.last_run_at,
    h.last_status,
    h.last_message,

    a.execution_state AS active_state,
    a.pid,
    a.started_at AS active_started_at,
    a.last_heartbeat,
    a.heartbeat_age_sec,

    CASE
        WHEN a.worker_name IS NOT NULL
             AND COALESCE(a.heartbeat_age_sec, 0) > 300
            THEN 'STALE_HEARTBEAT'

        WHEN COALESCE(h.failures_24h, 0) >= 5
            THEN 'CRITICAL'

        WHEN COALESCE(h.failures_24h, 0) >= 1
            THEN 'WARNING'

        WHEN d.scheduler_health_tier = 'WARNING'
            THEN 'WARNING'

        WHEN d.dashboard_state = 'READY'
            THEN 'OK'

        ELSE 'UNKNOWN'
    END AS worker_health_state,

    CASE
        WHEN a.worker_name IS NOT NULL
             AND COALESCE(a.heartbeat_age_sec, 0) > 300
            THEN 1

        WHEN COALESCE(h.failures_24h, 0) >= 5
            THEN 2

        WHEN COALESCE(h.failures_24h, 0) >= 1
            THEN 3

        WHEN d.scheduler_health_tier = 'WARNING'
            THEN 4

        WHEN d.dashboard_state = 'READY'
            THEN 9

        ELSE 99
    END AS health_rank

FROM dashboard d
FULL OUTER JOIN history_24h h
    ON LOWER(d.worker_code) = LOWER(h.worker_name)
FULL OUTER JOIN active_runs a
    ON LOWER(COALESCE(d.worker_code, h.worker_name)) = LOWER(a.worker_name);