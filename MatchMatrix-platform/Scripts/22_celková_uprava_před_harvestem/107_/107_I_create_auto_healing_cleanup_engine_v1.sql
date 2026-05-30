/*
MATCHMATRIX SQL 107_I
Create auto healing cleanup engine V1

CO TO JE:
- Připravený auto-healing cleanup engine pro runtime orchestration.
- Generuje bezpečné cleanup kandidáty pro stale/zombie execution sessions.

K ČEMU TO JE:
- Aby scheduler dokázal:
  automaticky recovernout runtime,
  odstranit stale locks,
  obnovit execution queue,
  zabránit permanentnímu zablokování orchestrace.

NA CO TO BUDE:
- autonomous scheduler
- runtime watchdog
- stale execution recovery
- self-healing orchestration
- scheduler recovery mode

KDE TO POUŽIJEME:
- ops.v_auto_healing_cleanup_engine_v1
- budoucí scheduler daemon
- budoucí cleanup executor
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_2.py
*/

CREATE OR REPLACE VIEW ops.v_auto_healing_cleanup_engine_v1 AS
SELECT
    g.worker_name,
    g.execution_state,
    g.pid,
    g.owner_id,
    g.lock_name,
    g.started_at,
    g.last_heartbeat,
    g.heartbeat_age_sec,
    g.heartbeat_status,
    g.cleanup_allowed,
    g.cleanup_reason,

    CASE
        WHEN g.cleanup_allowed IS TRUE
         AND g.heartbeat_status = 'NO_HEARTBEAT'
        THEN 'AUTO_REMOVE_RUNTIME_LOCK'

        WHEN g.cleanup_allowed IS TRUE
         AND g.heartbeat_status = 'STALE_HEARTBEAT'
        THEN 'AUTO_RECOVER_STALE_RUNTIME'

        ELSE 'NO_ACTION'
    END AS auto_healing_action,

    CASE
        WHEN g.cleanup_allowed IS TRUE
        THEN true
        ELSE false
    END AS eligible_for_auto_healing

FROM ops.v_runtime_cleanup_guard_v1 g;