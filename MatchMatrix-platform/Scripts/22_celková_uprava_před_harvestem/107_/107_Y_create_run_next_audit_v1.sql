/*
MATCHMATRIX SQL 107_Y
RUN NEXT Audit View V1

CO TO JE:
- Auditní view pro vysvětlení, proč worker je / není v RUN NEXT.

K ČEMU TO JE:
- Panel ukáže důvod blokace nebo povolení.
- Nebudeme hádat, proč scheduler něco nevybral.
- Připravuje V17.4 Runtime Metrics Panel.

KDE TO UVIDÍME:
- ops.v_run_next_audit_v1

JAK SE TO VYUŽIJE:
- RUN NEXT explain
- scheduler diagnostics
- panel debug
- orchestration governance
*/

CREATE OR REPLACE VIEW ops.v_run_next_audit_v1 AS
SELECT
    q.worker_code,
    q.worker_name,
    q.sport_code,
    q.entity,
    q.candidate_provider,
    q.run_group,

    q.execution_decision,
    q.retry_policy,
    q.autonomous_safe,
    q.orchestration_mode,

    q.execution_confidence_score,
    q.final_priority_score,

    q.ready_for_scheduler,
    q.final_ready_for_run_next,
    q.worker_already_running,
    q.has_pending_planner_job,
    q.planner_guard_state,
    q.run_next_state,

    CASE
        WHEN q.execution_decision IN ('BLOCK', 'BLOCK_TEMPORARY')
            THEN 'BLOCKED_BY_EXECUTION_CONFIDENCE'
        WHEN q.autonomous_safe IS NOT TRUE
            THEN 'NOT_AUTONOMOUS_SAFE'
        WHEN q.final_ready_for_run_next IS NOT TRUE
            THEN 'NOT_READY_FOR_RUN_NEXT'
        WHEN q.worker_already_running IS TRUE
            THEN 'WORKER_ALREADY_RUNNING'
        WHEN q.has_pending_planner_job IS NOT TRUE
            THEN 'NO_PENDING_PLANNER_JOB'
        ELSE 'READY_FOR_RUN_NEXT'
    END AS audit_reason,

    CASE
        WHEN q.execution_decision = 'RUN'
         AND q.autonomous_safe = true
         AND q.final_ready_for_run_next = true
            THEN true
        ELSE false
    END AS included_in_run_next

FROM ops.v_orchestration_priority_queue_v4 q
ORDER BY
    included_in_run_next DESC,
    final_priority_score DESC;