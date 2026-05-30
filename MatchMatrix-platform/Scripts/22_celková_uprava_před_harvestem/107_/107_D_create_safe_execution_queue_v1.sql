/*
MATCHMATRIX SQL 107_D
Create safe execution queue view V1

CO TO JE:
- Bezpečný execution queue view pro scheduler a panel.
- Propouští pouze routy, které mají validní production-safe worker.

K ČEMU TO JE:
- Aby scheduler nikdy nespustil:
  neexistující worker,
  disabled worker,
  non-runtime-ready worker,
  unsafe worker.

NA CO TO BUDE:
- SAFE AUTONOMOUS MODE
- RUN NEXT
- panel execution
- scheduler execution
- retry engine

KDE TO POUŽIJEME:
- ops.v_safe_execution_queue_v1
- future automation daemon
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17.py
*/

CREATE OR REPLACE VIEW ops.v_safe_execution_queue_v1 AS
SELECT
    r.sport_code,
    r.entity,
    r.candidate_provider,
    r.run_group,

    r.resolved_worker_script,

    r.worker_code,
    r.worker_name,

    r.layer_code,

    r.timeout_sec,
    r.max_attempts,

    r.worker_status,

    r.worker_can_run,
    r.worker_resolution_state,

    CASE
        WHEN r.worker_can_run IS TRUE
         AND r.worker_resolution_state = 'WORKER_READY'
        THEN true
        ELSE false
    END AS safe_to_execute

FROM ops.v_worker_resolver_v1 r
WHERE
    r.worker_can_run = true
    AND r.worker_resolution_state = 'WORKER_READY';