/*
MATCHMATRIX SQL 107_F
Create execution lock guard view V1

CO TO JE:
- Runtime execution lock guard pro scheduler a panel.
- Kontroluje, jestli už stejný worker neběží.

K ČEMU TO JE:
- Aby RUN NEXT nebo scheduler nespustil stejný worker paralelně.
- Ochrana proti:
  duplicitním harvestům,
  race conditions,
  deadlockům,
  lock konfliktům,
  chaosu v runtime.

NA CO TO BUDE:
- SAFE AUTONOMOUS MODE
- scheduler collision protection
- retry governance
- active execution ownership

KDE TO POUŽIJEME:
- ops.v_execution_lock_guard_v1
- future scheduler daemon
- RUN NEXT validation
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_1.py
*/

CREATE OR REPLACE VIEW ops.v_execution_lock_guard_v1 AS
SELECT
    q.sport_code,
    q.entity,
    q.candidate_provider,

    q.worker_code,
    q.worker_name,

    q.run_group,

    q.resolved_worker_script,

    q.safe_to_execute,

    ar.worker_name AS active_worker_name,
    ar.execution_state,
    ar.pid,
    ar.started_at,

    CASE
        WHEN ar.worker_name IS NOT NULL
        THEN true
        ELSE false
    END AS worker_already_running,

    CASE
        WHEN ar.worker_name IS NOT NULL
        THEN false
        ELSE true
    END AS execution_allowed

FROM ops.v_safe_execution_queue_v2 q
LEFT JOIN ops.active_worker_runs ar
    ON lower(ar.worker_name) = lower(q.worker_code)
    OR lower(ar.command_text) LIKE '%' || lower(q.worker_code) || '%';