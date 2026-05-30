/*
MATCHMATRIX SQL 106_H V1

Co to je:
Execution priority queue nad safe automation queue.

K čemu to je:
Počítá execution_priority_score pro scheduler:
- business priorita sportu
- priorita entity
- provider readiness
- run_group existence
- freshness / stale stav
- routing rank

Výsledek:
ops.v_execution_priority_queue_v1

Použití:
- future scheduler
- Control Panel priority tab
- autonomous orchestration
*/

CREATE OR REPLACE VIEW ops.v_execution_priority_queue_v1 AS

WITH base AS (

    SELECT
        q.*,

        CASE
            WHEN sport_code = 'FB' THEN 100
            WHEN sport_code = 'BK' THEN 90
            WHEN sport_code = 'HK' THEN 85
            WHEN sport_code = 'HB' THEN 75
            WHEN sport_code = 'VB' THEN 70
            WHEN sport_code = 'BSB' THEN 65
            WHEN sport_code = 'CK' THEN 60
            WHEN sport_code = 'AFB' THEN 55
            WHEN sport_code = 'RGB' THEN 50
            ELSE 10
        END AS sport_priority_score,

        CASE
            WHEN entity = 'fixtures' THEN 100
            WHEN entity = 'teams' THEN 80
            WHEN entity = 'leagues' THEN 70
            WHEN entity = 'players' THEN 60
            ELSE 10
        END AS entity_priority_score,

        CASE
            WHEN provider_route_state = 'CONFIRMED_PROVIDER' THEN 100
            WHEN provider_route_state = 'RUNNABLE_PROVIDER' THEN 80
            WHEN provider_route_state = 'PARTIAL_PROVIDER' THEN 50
            ELSE 10
        END AS provider_readiness_score,

        CASE
            WHEN run_group IS NOT NULL AND length(trim(run_group)) > 0 THEN 50
            ELSE 0
        END AS run_group_score,

        CASE
            WHEN last_run_at IS NULL THEN 50
            WHEN last_run_at < now() - interval '30 days' THEN 40
            WHEN last_run_at < now() - interval '14 days' THEN 25
            WHEN last_run_at < now() - interval '7 days' THEN 10
            ELSE 0
        END AS stale_score,

        CASE
            WHEN routing_rank = 1 THEN 30
            WHEN routing_rank = 2 THEN 10
            ELSE 0
        END AS routing_rank_score

    FROM ops.v_automation_ready_queue_v4 q
),

scored AS (

    SELECT
        *,

        (
            sport_priority_score
          + entity_priority_score
          + provider_readiness_score
          + run_group_score
          + stale_score
          + routing_rank_score
        ) AS execution_priority_score

    FROM base
)

SELECT
    sport_code,
    sport_name,
    entity,

    candidate_provider,
    primary_provider,
    fallback_provider,

    runtime_execution_state,
    run_group,
    resolved_worker_script,

    provider_route_state,
    provider_gap,
    runtime_state,
    production_readiness,

    last_run_at,
    next_action,

    sport_priority_score,
    entity_priority_score,
    provider_readiness_score,
    run_group_score,
    stale_score,
    routing_rank_score,

    execution_priority_score,

    routing_rank

FROM scored

ORDER BY
    execution_priority_score DESC,
    sport_code,
    entity,
    routing_rank;