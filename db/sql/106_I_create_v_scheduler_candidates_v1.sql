/*
MATCHMATRIX SQL 106_I V1

Co to je:
Scheduler candidates view nad execution priority queue.

K čemu to je:
Vybere nejlepšího kandidáta pro každý sport + entity.
Odstraní duplicitní fallback řádky a ponechá nejvhodnější routu.

Výsledek:
ops.v_scheduler_candidates_v1

Použití:
- budoucí scheduler
- Control Panel scheduler tab
- autonomous orchestration
- RUN NEXT BEST JOB
*/

CREATE OR REPLACE VIEW ops.v_scheduler_candidates_v1 AS

WITH ranked AS (

    SELECT
        q.*,

        ROW_NUMBER() OVER (
            PARTITION BY q.sport_code, q.entity
            ORDER BY
                q.execution_priority_score DESC,
                q.routing_rank ASC,
                q.candidate_provider ASC
        ) AS candidate_rank

    FROM ops.v_execution_priority_queue_v1 q

    WHERE
        q.resolved_worker_script IS NOT NULL

        AND q.runtime_execution_state = 'CAN_RUN_NOW_RUNTIME'

        AND q.candidate_provider NOT IN (
            'football_data'
        )

        AND NOT (
            q.sport_code = 'BK'
            AND q.candidate_provider = 'api_basketball'
            AND (
                q.run_group IS NULL
                OR length(trim(q.run_group)) = 0
            )
        )
)

SELECT
    sport_code,
    sport_name,
    entity,

    candidate_provider,
    primary_provider,
    fallback_provider,

    run_group,
    resolved_worker_script,

    runtime_execution_state,

    provider_route_state,
    provider_gap,
    runtime_state,
    production_readiness,

    last_run_at,
    next_action,

    execution_priority_score,

    sport_priority_score,
    entity_priority_score,
    provider_readiness_score,
    run_group_score,
    stale_score,
    routing_rank_score,

    routing_rank,
    candidate_rank

FROM ranked

WHERE candidate_rank = 1

ORDER BY
    execution_priority_score DESC,
    sport_code,
    entity;