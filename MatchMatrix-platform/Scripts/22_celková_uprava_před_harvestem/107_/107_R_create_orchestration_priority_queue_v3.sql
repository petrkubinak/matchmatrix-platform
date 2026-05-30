/*
MATCHMATRIX SQL 107_R
Create orchestration priority queue V3

CO TO JE:
- Finální RUN NEXT fronta s planner pending guardem.
- Do fronty propustí pouze routy, které:
  mají safe worker,
  nejsou zamčené,
  jsou dependency-ready,
  mají reálný pending/retry planner job.

K ČEMU TO JE:
- Aby RUN NEXT nikdy nespouštěl prázdný run.
- Aby scheduler bral jen skutečně připravenou práci.
- Aby panel zobrazoval realistickou execution queue.

NA CO TO BUDE:
- SMART RUN NEXT
- V17.3 panel
- autonomous scheduler
- planner-aware orchestration
- future autopilot

KDE TO POUŽIJEME:
- ops.v_orchestration_priority_queue_v3
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_3.py
- future automation daemon
*/

CREATE OR REPLACE VIEW ops.v_orchestration_priority_queue_v3 AS
SELECT
    q.orchestration_priority_rank,
    q.effective_layer_order,

    q.sport_code,
    q.entity,
    q.candidate_provider,

    q.worker_code,
    q.worker_name,
    q.run_group,
    q.resolved_worker_script,

    q.timeout_sec,
    q.max_attempts,

    q.worker_status,
    q.orchestration_state,
    q.worker_already_running,
    q.execution_allowed,
    q.ready_for_scheduler,

    p.planner_job_id,
    p.planner_job_status,
    p.planner_priority,
    p.has_pending_planner_job,
    p.planner_guard_state,

    CASE
        WHEN q.ready_for_scheduler IS TRUE
         AND p.has_pending_planner_job IS TRUE
        THEN true
        ELSE false
    END AS final_ready_for_run_next,

    CASE
        WHEN q.ready_for_scheduler IS NOT TRUE
        THEN 'BLOCKED_NOT_READY_FOR_SCHEDULER'

        WHEN p.has_pending_planner_job IS NOT TRUE
        THEN 'BLOCKED_NO_PENDING_PLANNER_JOB'

        ELSE 'READY_FOR_RUN_NEXT'
    END AS run_next_state

FROM ops.v_orchestration_priority_queue_v2 q

LEFT JOIN ops.v_planner_pending_guard_v2 p
    ON p.sport_code = q.sport_code
   AND p.entity = q.entity
   AND p.candidate_provider = q.candidate_provider
   AND p.run_group IS NOT DISTINCT FROM q.run_group

WHERE
    q.ready_for_scheduler IS TRUE
    AND p.has_pending_planner_job IS TRUE;