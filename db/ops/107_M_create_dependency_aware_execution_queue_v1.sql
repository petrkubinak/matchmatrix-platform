/*
MATCHMATRIX SQL 107_M
Create dependency-aware execution queue V1

CO TO JE:
- Rozšířená SAFE execution queue s dependency intelligence.
- Scheduler vidí:
  layer pořadí,
  dependency readiness,
  orchestration chain.

K ČEMU TO JE:
- Aby scheduler věděl:
  co může běžet teď,
  co musí čekat,
  co je blokované dependency chainem.

- Základ budoucího DAG scheduleru.

NA CO TO BUDE:
- dependency-aware RUN NEXT
- autonomous scheduler
- orchestration sequencing
- future multi-layer automation
- smart execution ordering

KDE TO POUŽIJEME:
- ops.v_dependency_aware_execution_queue_v1
- future scheduler daemon
- panel orchestration tab
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_2.py
*/

CREATE OR REPLACE VIEW ops.v_dependency_aware_execution_queue_v1 AS
SELECT
    q.sport_code,
    q.entity,
    q.candidate_provider,

    q.worker_code,
    q.worker_name,

    q.run_group,

    q.timeout_sec,
    q.max_attempts,

    q.worker_status,

    q.worker_resolution_state,
    q.safe_to_execute,

    d.parent_worker_code,
    d.parent_worker_name,

    d.child_worker_code,
    d.child_worker_name,

    d.dependency_type,

    d.layer_order,
    d.child_layer_order,

    d.dependency_runtime_ready,
    d.dependency_state,

    CASE
        WHEN q.safe_to_execute IS TRUE
         AND (
             d.dependency_runtime_ready IS TRUE
             OR d.dependency_runtime_ready IS NULL
         )
        THEN true
        ELSE false
    END AS dependency_execution_allowed,

    CASE
        WHEN q.safe_to_execute IS NOT TRUE
        THEN 'BLOCKED_SAFE_EXECUTION'

        WHEN d.dependency_runtime_ready IS FALSE
        THEN 'BLOCKED_DEPENDENCY'

        ELSE 'READY_FOR_ORCHESTRATION'
    END AS orchestration_state

FROM ops.v_safe_execution_queue_v2 q

LEFT JOIN ops.v_dependency_resolver_v1 d
    ON d.child_worker_code = q.worker_code;