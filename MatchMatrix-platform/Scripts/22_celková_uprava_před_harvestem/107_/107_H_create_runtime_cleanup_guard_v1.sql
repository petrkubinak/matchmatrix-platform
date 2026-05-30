/*
MATCHMATRIX SQL 107_H
Create runtime cleanup guard V1

CO TO JE:
- Bezpečný cleanup guard pro stale/zombie runtime záznamy.
- Nevytváří mazací akci automaticky, jen připraví kontrolovaný view.

K ČEMU TO JE:
- Abychom přesně viděli, které active_worker_runs jsou bezpečné ke cleanupu.
- Aby scheduler později neumíral na starých locech.
- Aby RUN NEXT nebyl blokovaný mrtvým procesem.

NA CO TO BUDE:
- runtime watchdog
- stale lock cleanup
- autonomous scheduler
- panel V17.2
- auto-healing orchestration

KDE TO POUŽIJEME:
- ops.v_runtime_cleanup_guard_v1
- budoucí cleanup skript
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_2.py
*/

CREATE OR REPLACE VIEW ops.v_runtime_cleanup_guard_v1 AS
SELECT
    h.worker_name,
    h.execution_state,
    h.pid,
    h.owner_id,
    h.lock_name,
    h.started_at,
    h.last_heartbeat,
    h.heartbeat_age_sec,
    h.heartbeat_status,
    h.requires_runtime_cleanup,

    CASE
        WHEN h.requires_runtime_cleanup IS TRUE
         AND h.heartbeat_status IN ('NO_HEARTBEAT', 'STALE_HEARTBEAT')
        THEN true
        ELSE false
    END AS cleanup_allowed,

    CASE
        WHEN h.heartbeat_status = 'NO_HEARTBEAT'
        THEN 'CLEANUP_ALLOWED_NO_HEARTBEAT'

        WHEN h.heartbeat_status = 'STALE_HEARTBEAT'
        THEN 'CLEANUP_ALLOWED_STALE_HEARTBEAT'

        WHEN h.heartbeat_status = 'WARNING_HEARTBEAT'
        THEN 'WAIT_HEARTBEAT_WARNING_ONLY'

        WHEN h.heartbeat_status = 'HEALTHY'
        THEN 'NO_CLEANUP_HEALTHY'

        ELSE 'NO_CLEANUP_UNKNOWN'
    END AS cleanup_reason

FROM ops.v_runtime_heartbeat_governance_v1 h;