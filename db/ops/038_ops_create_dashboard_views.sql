-- ==========================================================
-- MATCHMATRIX
-- 038_ops_create_dashboard_views.sql
--
-- Kam uložit:
-- C:\MatchMatrix-platform\db\038_ops_create_dashboard_views.sql
--
-- Co dělá:
-- Vytvoří základní OPS dashboard views pro přehled nad:
-- - ops.ingest_planner
-- - ops.job_runs
-- - ops.worker_locks
--
-- View:
-- 1) ops.v_ingest_planner_status
-- 2) ops.v_ingest_planner_queue
-- 3) ops.v_job_runs_recent
-- 4) ops.v_worker_locks_active
-- 5) ops.v_ops_dashboard_summary
-- ==========================================================

CREATE SCHEMA IF NOT EXISTS ops;

-- ----------------------------------------------------------
-- 1) Souhrn planneru podle stavů
-- ----------------------------------------------------------
CREATE OR REPLACE VIEW ops.v_ingest_planner_status AS
SELECT
    p.provider,
    p.sport_code,
    p.entity,
    COALESCE(p.run_group, '(null)') AS run_group,
    p.status,
    COUNT(*)::integer AS jobs_count,
    MIN(p.priority) AS min_priority,
    MAX(p.priority) AS max_priority,
    MIN(p.next_run) AS next_run_min,
    MAX(p.next_run) AS next_run_max,
    MAX(p.updated_at) AS last_updated_at
FROM ops.ingest_planner p
GROUP BY
    p.provider,
    p.sport_code,
    p.entity,
    COALESCE(p.run_group, '(null)'),
    p.status;

COMMENT ON VIEW ops.v_ingest_planner_status IS
'Planner job counts grouped by provider/sport/entity/run_group/status.';


-- ----------------------------------------------------------
-- 2) Fronta planneru - detail pro pending/running/error
-- ----------------------------------------------------------
CREATE OR REPLACE VIEW ops.v_ingest_planner_queue AS
SELECT
    p.id,
    p.provider,
    p.sport_code,
    p.entity,
    p.provider_league_id,
    p.season,
    p.run_group,
    p.priority,
    p.status,
    p.attempts,
    p.last_attempt,
    p.next_run,
    p.created_at,
    p.updated_at,
    CASE
        WHEN p.status = 'pending'
             AND (p.next_run IS NULL OR p.next_run <= NOW())
        THEN true
        ELSE false
    END AS is_ready_now
FROM ops.ingest_planner p
WHERE p.status IN ('pending', 'running', 'error')
ORDER BY
    CASE p.status
        WHEN 'running' THEN 1
        WHEN 'error'   THEN 2
        WHEN 'pending' THEN 3
        ELSE 9
    END,
    COALESCE(p.priority, 999999),
    p.id;

COMMENT ON VIEW ops.v_ingest_planner_queue IS
'Detailed queue of pending/running/error planner jobs.';


-- ----------------------------------------------------------
-- 3) Poslední job runs
-- ----------------------------------------------------------
CREATE OR REPLACE VIEW ops.v_job_runs_recent AS
SELECT
    jr.id,
    jr.job_code,
    jr.started_at,
    jr.finished_at,
    jr.status,
    jr.message,
    jr.rows_affected,
    CASE
        WHEN jr.finished_at IS NOT NULL
        THEN EXTRACT(EPOCH FROM (jr.finished_at - jr.started_at))::integer
        ELSE NULL
    END AS duration_sec,
    jr.params,
    jr.details,
    jr.created_at
FROM ops.job_runs jr
ORDER BY jr.id DESC;

COMMENT ON VIEW ops.v_job_runs_recent IS
'Recent job runs ordered from newest to oldest.';


-- ----------------------------------------------------------
-- 4) Aktivní / neexpirované locky
-- ----------------------------------------------------------
CREATE OR REPLACE VIEW ops.v_worker_locks_active AS
SELECT
    wl.lock_name,
    wl.owner_id,
    wl.acquired_at,
    wl.expires_at,
    wl.heartbeat_at,
    wl.note,
    wl.created_at,
    wl.updated_at,
    CASE
        WHEN wl.expires_at IS NOT NULL AND wl.expires_at > NOW()
        THEN true
        ELSE false
    END AS is_active,
    CASE
        WHEN wl.expires_at IS NOT NULL
        THEN EXTRACT(EPOCH FROM (wl.expires_at - NOW()))::integer
        ELSE NULL
    END AS seconds_to_expire
FROM ops.worker_locks wl
WHERE wl.expires_at IS NULL
   OR wl.expires_at > NOW()
ORDER BY wl.expires_at;

COMMENT ON VIEW ops.v_worker_locks_active IS
'Currently active worker locks (non-expired locks).';


-- ----------------------------------------------------------
-- 5) Jednořádkový dashboard summary
-- ----------------------------------------------------------
CREATE OR REPLACE VIEW ops.v_ops_dashboard_summary AS
WITH planner AS (
    SELECT
        COUNT(*) FILTER (WHERE status = 'pending')::integer AS planner_pending,
        COUNT(*) FILTER (WHERE status = 'running')::integer AS planner_running,
        COUNT(*) FILTER (WHERE status = 'done')::integer AS planner_done,
        COUNT(*) FILTER (WHERE status = 'error')::integer AS planner_error,
        COUNT(*) FILTER (
            WHERE status = 'pending'
              AND (next_run IS NULL OR next_run <= NOW())
        )::integer AS planner_ready_now
    FROM ops.ingest_planner
),
locks AS (
    SELECT
        COUNT(*) FILTER (
            WHERE expires_at IS NULL OR expires_at > NOW()
        )::integer AS active_locks
    FROM ops.worker_locks
),
last_cycle AS (
    SELECT
        jr.id AS last_cycle_job_run_id,
        jr.status AS last_cycle_status,
        jr.started_at AS last_cycle_started_at,
        jr.finished_at AS last_cycle_finished_at,
        jr.message AS last_cycle_message,
        jr.rows_affected AS last_cycle_rows_affected
    FROM ops.job_runs jr
    WHERE jr.job_code = 'ingest_cycle_v2'
    ORDER BY jr.id DESC
    LIMIT 1
),
last_planner_worker AS (
    SELECT
        jr.id AS last_planner_job_run_id,
        jr.status AS last_planner_status,
        jr.started_at AS last_planner_started_at,
        jr.finished_at AS last_planner_finished_at,
        jr.message AS last_planner_message
    FROM ops.job_runs jr
    WHERE jr.job_code = 'ingest_planner_worker'
    ORDER BY jr.id DESC
    LIMIT 1
),
last_merge AS (
    SELECT
        jr.id AS last_merge_job_run_id,
        jr.status AS last_merge_status,
        jr.started_at AS last_merge_started_at,
        jr.finished_at AS last_merge_finished_at,
        jr.message AS last_merge_message
    FROM ops.job_runs jr
    WHERE jr.job_code IN ('unified_staging_to_public_merge', 'run_unified_staging_to_public_merge_v1')
    ORDER BY jr.id DESC
    LIMIT 1
)
SELECT
    planner.planner_pending,
    planner.planner_running,
    planner.planner_done,
    planner.planner_error,
    planner.planner_ready_now,
    locks.active_locks,

    last_cycle.last_cycle_job_run_id,
    last_cycle.last_cycle_status,
    last_cycle.last_cycle_started_at,
    last_cycle.last_cycle_finished_at,
    last_cycle.last_cycle_message,
    last_cycle.last_cycle_rows_affected,

    last_planner_worker.last_planner_job_run_id,
    last_planner_worker.last_planner_status,
    last_planner_worker.last_planner_started_at,
    last_planner_worker.last_planner_finished_at,
    last_planner_worker.last_planner_message,

    last_merge.last_merge_job_run_id,
    last_merge.last_merge_status,
    last_merge.last_merge_started_at,
    last_merge.last_merge_finished_at,
    last_merge.last_merge_message
FROM planner
CROSS JOIN locks
LEFT JOIN last_cycle ON true
LEFT JOIN last_planner_worker ON true
LEFT JOIN last_merge ON true;

COMMENT ON VIEW ops.v_ops_dashboard_summary IS
'One-row operational summary for planner, cycle, merge and locks.';