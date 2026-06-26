/*
MATCHMATRIX SQL 107_P
Create planner pending guard V1

CO TO JE:
- Guard vrstva mezi schedulerem a planner queue.
- Kontroluje, jestli orchestration kandidát má skutečný pending planner job.

K ČEMU TO JE:
- Aby RUN NEXT nespouštěl prázdné execution runy.
- Aby scheduler vybíral jen routy, kde existuje práce.

NA CO TO BUDE:
- SMART RUN NEXT
- autonomous scheduler
- planner-aware orchestration
- execution optimization
- anti-empty-run protection

KDE TO POUŽIJEME:
- ops.v_planner_pending_guard_v1
- ops.v_orchestration_priority_queue_v3
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_3.py
*/

CREATE OR REPLACE VIEW ops.v_planner_pending_guard_v1 AS
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

    CASE
        WHEN p.id IS NOT NULL
         AND p.status IN ('pending', 'retry')
        THEN true
        ELSE false
    END AS has_pending_planner_job,

    CASE
        WHEN p.id IS NOT NULL
         AND p.status IN ('pending', 'retry')
        THEN 'READY_PENDING_JOB_EXISTS'

        WHEN p.id IS NOT NULL
        THEN 'PLANNER_JOB_NOT_PENDING'

        ELSE 'NO_PENDING_PLANNER_JOB'
    END AS planner_guard_state

FROM ops.v_orchestration_priority_queue_v2 q

LEFT JOIN ops.ingest_planner p
    ON p.run_group = q.run_group
   AND p.sport_code = q.sport_code
   AND p.entity = q.entity
   AND p.provider = q.candidate_provider;