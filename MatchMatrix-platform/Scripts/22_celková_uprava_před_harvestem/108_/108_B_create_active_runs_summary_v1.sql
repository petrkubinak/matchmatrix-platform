/*
MATCHMATRIX SQL 108_B
Active Runs Summary V1

CO TO JE:
- Souhrn active runtime locků pro panel.
- Počítá zdravé, stale a expirované locky.

K ČEMU TO JE:
- Panel V17.5 dostane jednoduchý status:
  HEALTHY / WARNING / CRITICAL.
- Scheduler pozná, jestli běží něco problematického.

KDE TO UVIDÍME:
- ops.v_active_runs_summary_v1
- Panel V17.5 horní status bar

JAK SE TO VYUŽIJE:
- live scheduler status
- heartbeat warning
- stale lock diagnostics
- runtime governance
*/

CREATE OR REPLACE VIEW ops.v_active_runs_summary_v1 AS
SELECT
    COUNT(*) AS active_lock_count,

    COUNT(*) FILTER (
        WHERE live_state = 'ACTIVE_HEALTHY'
    ) AS healthy_lock_count,

    COUNT(*) FILTER (
        WHERE live_state = 'ACTIVE_STALE_HEARTBEAT'
    ) AS stale_heartbeat_count,

    COUNT(*) FILTER (
        WHERE live_state = 'EXPIRED_LOCK'
    ) AS expired_lock_count,

    CASE
        WHEN COUNT(*) FILTER (WHERE live_state = 'EXPIRED_LOCK') > 0
            THEN 'CRITICAL'

        WHEN COUNT(*) FILTER (WHERE live_state = 'ACTIVE_STALE_HEARTBEAT') > 0
            THEN 'WARNING'

        WHEN COUNT(*) FILTER (WHERE live_state = 'ACTIVE_HEALTHY') > 0
            THEN 'HEALTHY'

        ELSE 'IDLE'
    END AS active_runs_status,

    CASE
        WHEN COUNT(*) FILTER (WHERE live_state = 'EXPIRED_LOCK') > 0
            THEN 'RED'

        WHEN COUNT(*) FILTER (WHERE live_state = 'ACTIVE_STALE_HEARTBEAT') > 0
            THEN 'YELLOW'

        WHEN COUNT(*) FILTER (WHERE live_state = 'ACTIVE_HEALTHY') > 0
            THEN 'GREEN'

        ELSE 'GRAY'
    END AS active_runs_color,

    MAX(acquired_at) AS last_lock_acquired_at,
    MAX(heartbeat_at) AS last_heartbeat_at

FROM ops.v_active_runs_live_v1;