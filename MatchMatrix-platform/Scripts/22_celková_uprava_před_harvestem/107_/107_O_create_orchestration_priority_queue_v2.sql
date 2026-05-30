/*
MATCHMATRIX SQL 107_O
Create orchestration priority queue V2

CO TO JE:
- Opravená finální orchestration priority queue.
- Doplňuje vlastní worker layer order podle worker_code.
- Řeší problém, kdy PEOPLE šlo před CORE kvůli NULL layer_order.

K ČEMU TO JE:
- Aby scheduler vždy řadil:
  CORE → PEOPLE → MEDIA → MERGE → MATCHING.

NA CO TO BUDE:
- RUN NEXT
- autonomous scheduler
- orchestration daemon
- smart execution ordering
- future autopilot

KDE TO POUŽIJEME:
- ops.v_orchestration_priority_queue_v2
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_2.py
- future automation daemon
*/

CREATE OR REPLACE VIEW ops.v_orchestration_priority_queue_v2 AS
SELECT
    base.*,

    ROW_NUMBER() OVER (
        ORDER BY
            base.effective_layer_order,
            base.routing_rank,
            base.sport_code,
            base.entity
    ) AS orchestration_priority_rank

FROM (
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

        CASE
            WHEN d.worker_code = 'CORE_INGEST_V3' THEN 100
            WHEN d.worker_code = 'PEOPLE_PIPELINE_V22' THEN 200
            WHEN d.worker_code = 'MEDIA_PIPELINE_V1' THEN 300
            WHEN d.worker_code = 'MEDIA_MERGE_V1' THEN 400
            WHEN d.worker_code = 'MATCH_ARTICLE_ENTITIES_V1' THEN 500
            WHEN d.worker_code = 'MATCH_ARTICLE_PLAYERS_V1' THEN 600
            ELSE 999
        END AS effective_layer_order,

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
        END AS ready_for_scheduler

    FROM ops.v_dependency_aware_execution_queue_v1 d

    LEFT JOIN ops.v_execution_lock_guard_v1 l
        ON l.sport_code = d.sport_code
       AND l.entity = d.entity
       AND l.worker_code = d.worker_code

    LEFT JOIN ops.v_automation_ready_queue_v4 a
        ON a.sport_code = d.sport_code
       AND a.entity = d.entity
       AND a.candidate_provider = d.candidate_provider
) base;