/*
MATCHMATRIX SQL 107_X
Final RUN NEXT Queue V1

CO TO JE:
- Finální autonomous RUN NEXT queue.
- Scheduler už vybírá pouze execution-safe workery.

K ČEMU TO JE:
- RUN NEXT bude production-ready.
- Scheduler už nebude vybírat:
    BLOCK
    BLOCK_TEMPORARY
    unsafe orchestration

CO RESPEKTUJE:
- dependency ordering
- planner pending jobs
- runtime governance
- execution confidence
- retry policy
- autonomous safety

KDE TO UVIDÍME:
- ops.v_run_next_queue_v1
- Panel V17.4

JAK SE TO VYUŽIJE:
- autonomous orchestration
- self-healing scheduler
- intelligent execution routing
- enterprise runtime governance
*/

CREATE OR REPLACE VIEW ops.v_run_next_queue_v1 AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            q.final_priority_score DESC,
            q.effective_layer_order ASC
    ) AS run_next_rank,

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

    q.effective_layer_order,

    q.resolved_worker_script,

    q.timeout_sec,
    q.max_attempts,

    q.planner_job_id,
    q.planner_priority,

    q.worker_status,
    q.orchestration_state,

    q.ready_for_scheduler,
    q.final_ready_for_run_next

FROM ops.v_orchestration_priority_queue_v4 q

WHERE 1=1

    /* ONLY SAFE EXECUTION */
    AND q.execution_decision = 'RUN'

    /* ONLY AUTONOMOUS SAFE */
    AND q.autonomous_safe = true

    /* ONLY READY */
    AND q.final_ready_for_run_next = true

ORDER BY
    q.final_priority_score DESC,
    q.effective_layer_order ASC;