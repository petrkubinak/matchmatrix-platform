/*
MATCHMATRIX SQL 107_G
Create runtime heartbeat governance view V1

CO TO JE:
- Runtime heartbeat governance vrstva pro orchestration systém.
- Kontroluje stáří heartbeatů aktivních workerů.

K ČEMU TO JE:
- Detekce:
  zombie workerů,
  zamrzlých procesů,
  stale locků,
  dead runtime session.

- Scheduler potom nebude blokovaný starým lockem.

NA CO TO BUDE:
- AUTO HEALING scheduler
- stale lock cleanup
- runtime governance
- autonomous orchestration
- worker watchdog

KDE TO POUŽIJEME:
- ops.v_runtime_heartbeat_governance_v1
- budoucí scheduler daemon
- budoucí runtime watchdog
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_2.py
*/

CREATE OR REPLACE VIEW ops.v_runtime_heartbeat_governance_v1 AS
SELECT
    worker_name,
    execution_state,
    pid,
    owner_id,
    lock_name,
    started_at,
    last_heartbeat,

    EXTRACT(
        EPOCH FROM (now() - last_heartbeat)
    )::INTEGER AS heartbeat_age_sec,

    CASE
        WHEN last_heartbeat IS NULL
        THEN 'NO_HEARTBEAT'

        WHEN now() - last_heartbeat > interval '10 minutes'
        THEN 'STALE_HEARTBEAT'

        WHEN now() - last_heartbeat > interval '5 minutes'
        THEN 'WARNING_HEARTBEAT'

        ELSE 'HEALTHY'
    END AS heartbeat_status,

    CASE
        WHEN last_heartbeat IS NULL
        THEN true

        WHEN now() - last_heartbeat > interval '10 minutes'
        THEN true

        ELSE false
    END AS requires_runtime_cleanup

FROM ops.active_worker_runs;