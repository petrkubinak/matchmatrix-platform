/*
MATCHMATRIX SQL 107_Q
Create planner pending guard V2

CO TO JE:
- Opravený planner pending guard s deduplikací planner queue.
- Z každé route bere jen jeden nejlepší pending/retry planner job.

K ČEMU TO JE:
- Aby scheduler neviděl stovky stejných route.
- Aby RUN NEXT měl čistou orchestration queue.
- Aby priority engine fungoval správně.

NA CO TO BUDE:
- SMART RUN NEXT
- planner-aware scheduler
- orchestration normalization
- queue deduplication
- future automation daemon

KDE TO POUŽIJEME:
- ops.v_planner_pending_guard_v2
- future orchestration queue V4
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_3.py
*/

CREATE OR REPLACE VIEW ops.v_planner_pending_guard_v2 AS

WITH planner_ranked AS (
    SELECT
        p.*,

        ROW_NUMBER() OVER (
            PARTITION BY
                p.sport_code,
                p.entity,
                p.provider,
                COALESCE(p.run_group, '')
            ORDER BY
                CASE
                    WHEN p.status = 'retry' THEN 1
                    WHEN p.status = 'pending' THEN 2
                    ELSE 999
                END,
                p.priority NULLS LAST,
                p.id
        ) AS planner_rank

    FROM ops.ingest_planner p
    WHERE p.status IN ('pending', 'retry')
)

SELECT
    q.orchestration_priority_rank,

    q.sport_code,
    q.entity,
    q.candidate_provider,

    q.worker_code,
    q.worker_name,

    q.run_group,

    q.ready_for_scheduler,

    p.id AS planner_job_id,
    p.status AS planner_job_status,

    p.provider AS planner_provider,
    p.sport_code AS planner_sport_code,
    p.entity AS planner_entity,
    p.run_group AS planner_run_group,

    p.priority AS planner_priority,

    CASE
        WHEN p.id IS NOT NULL
        THEN true
        ELSE false
    END AS has_pending_planner_job,

    CASE
        WHEN p.id IS NOT NULL
        THEN 'READY_PENDING_JOB_EXISTS'
        ELSE 'NO_PENDING_PLANNER_JOB'
    END AS planner_guard_state

FROM ops.v_orchestration_priority_queue_v2 q

LEFT JOIN planner_ranked p
    ON p.run_group IS NOT DISTINCT FROM q.run_group
   AND p.sport_code = q.sport_code
   AND p.entity = q.entity
   AND p.provider = q.candidate_provider
   AND p.planner_rank = 1;