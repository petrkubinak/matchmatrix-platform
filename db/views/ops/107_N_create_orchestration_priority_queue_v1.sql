/*
MATCHMATRIX SQL 107_N
Create orchestration priority queue V1

CO TO JE:
- Finální orchestration priority queue pro RUN NEXT a scheduler.
- Kombinuje:
  SAFE execution,
  dependency governance,
  runtime lock guard,
  provider priority.

K ČEMU TO JE:
- Aby scheduler věděl:
  co je nejlepší kandidát,
  co není zamčené,
  co je dependency-ready,
  co je runtime-safe.

- Toto je hlavní queue pro autonomní orchestration.

NA CO TO BUDE:
- RUN NEXT
- autonomous scheduler
- orchestration daemon
- smart execution ordering
- future autopilot

KDE TO POUŽIJEME:
- ops.v_orchestration_priority_queue_v1
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_2.py
- future automation daemon
*/

CREATE OR REPLACE VIEW ops.v_orchestration_priority_queue_v1 AS
SELECT
    d.sport_code,
    d.entity,
    d.candidate_provider,

    d.worker_code,
    d.worker_name,

    d.run_group,

    d.timeout_sec,
    d.max_attempts,

    d.worker_status,

    d.parent_worker_code,
    d.parent_worker_name,

    d.layer_order,
    d.child_layer_order,

    d.dependency_runtime_ready,
    d.dependency_execution_allowed,
    d.orchestration_state,

    l.worker_already_running,
    l.execution_allowed,

    a.routing_rank,

    CASE
        WHEN d.orchestration_state = 'READY_FOR_ORCHESTRATION'
         AND l.execution_allowed = true
         AND d.dependency_execution_allowed = true
        THEN true
        ELSE false
    END AS ready_for_scheduler,

    ROW_NUMBER() OVER (
        ORDER BY
            COALESCE(d.layer_order, 999),
            COALESCE(d.child_layer_order, 999),
            a.routing_rank,
            d.sport_code,
            d.entity
    ) AS orchestration_priority_rank

FROM ops.v_dependency_aware_execution_queue_v1 d

LEFT JOIN ops.v_execution_lock_guard_v1 l
    ON l.sport_code = d.sport_code
   AND l.entity = d.entity
   AND l.worker_code = d.worker_code

LEFT JOIN ops.v_automation_ready_queue_v4 a
    ON a.sport_code = d.sport_code
   AND a.entity = d.entity
   AND a.candidate_provider = d.candidate_provider;