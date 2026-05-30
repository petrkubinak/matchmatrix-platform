/*
MATCHMATRIX SQL 108_D
Scheduler Queue Summary V1

CO TO JE:
- Souhrn orchestration scheduler queue.
- Ukazuje:
  - runnable workery
  - blocked workery
  - retry limited workery
  - SAFE autonomous ready workery

K ČEMU TO JE:
- Panel V17.6 dostane:
  - scheduler load
  - orchestration readiness
  - blocked runtime state

KDE TO UVIDÍME:
- ops.v_scheduler_queue_summary_v1
- Scheduler KPI cards

JAK SE TO VYUŽIJE:
- orchestration governance
- scheduler diagnostics
- autonomous execution monitoring
*/

CREATE OR REPLACE VIEW ops.v_scheduler_queue_summary_v1 AS
SELECT

    COUNT(*) AS total_scheduler_workers,

    COUNT(*) FILTER (
        WHERE execution_decision = 'RUN'
    ) AS runnable_workers,

    COUNT(*) FILTER (
        WHERE execution_decision IN (
            'BLOCK',
            'BLOCK_TEMPORARY'
        )
    ) AS blocked_workers,

    COUNT(*) FILTER (
        WHERE execution_decision = 'RETRY_LIMITED'
    ) AS retry_limited_workers,

    COUNT(*) FILTER (
        WHERE autonomous_safe = true
          AND execution_decision = 'RUN'
    ) AS safe_autonomous_workers,

    COUNT(*) FILTER (
        WHERE included_in_run_next = true
    ) AS run_next_workers,

    MAX(final_priority_score) AS max_priority_score,
    AVG(execution_confidence_score) AS avg_confidence_score,

    CASE
        WHEN COUNT(*) FILTER (
            WHERE execution_decision IN (
                'BLOCK',
                'BLOCK_TEMPORARY'
            )
        ) > 10
            THEN 'CRITICAL'

        WHEN COUNT(*) FILTER (
            WHERE execution_decision = 'RETRY_LIMITED'
        ) > 5
            THEN 'WARNING'

        WHEN COUNT(*) FILTER (
            WHERE execution_decision = 'RUN'
        ) > 0
            THEN 'READY'

        ELSE 'IDLE'
    END AS scheduler_state,

    CASE
        WHEN COUNT(*) FILTER (
            WHERE execution_decision IN (
                'BLOCK',
                'BLOCK_TEMPORARY'
            )
        ) > 10
            THEN 'RED'

        WHEN COUNT(*) FILTER (
            WHERE execution_decision = 'RETRY_LIMITED'
        ) > 5
            THEN 'YELLOW'

        WHEN COUNT(*) FILTER (
            WHERE execution_decision = 'RUN'
        ) > 0
            THEN 'GREEN'

        ELSE 'PURPLE'
    END AS scheduler_color

FROM ops.v_scheduler_runtime_dashboard_v1;