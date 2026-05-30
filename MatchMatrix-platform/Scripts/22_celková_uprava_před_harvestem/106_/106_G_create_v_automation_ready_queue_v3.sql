/*
MATCHMATRIX SQL 106_G V3

Co to je:
Pragmatic runtime-ready queue pro launcher / Control Panel.

K čemu to je:
Překládá auditní stav na skutečný runtime stav.
Audit může říkat BLOCKED_PROVIDER kvůli chybějícímu fallbacku nebo worker_scriptu,
ale launcher umí některé entity spustit přes default worker.

Výsledek:
ops.v_automation_ready_queue_v3
*/

CREATE OR REPLACE VIEW ops.v_automation_ready_queue_v3 AS

WITH q AS (
    SELECT
        *,

        CASE
            WHEN worker_script IS NOT NULL THEN worker_script
            WHEN entity IN ('fixtures', 'teams', 'leagues') THEN 'workers/run_ingest_cycle_v3.py'
            WHEN entity IN ('players', 'coaches', 'player_stats', 'player_season_stats') THEN 'workers/run_people_pipeline_v22_from_planner.py'
            WHEN entity IN ('articles', 'media', 'highlights', 'comments') THEN 'workers/run_media_pipeline_v1.py'
            ELSE NULL
        END AS resolved_worker_script

    FROM ops.v_automation_execution_queue_v2
),

r AS (
    SELECT
        *,

        CASE
            WHEN provider_route_state IN (
                'CONFIRMED_PROVIDER',
                'RUNNABLE_PROVIDER',
                'PARTIAL_PROVIDER'
            )
            AND routing_candidate IS TRUE
            AND resolved_worker_script IS NOT NULL
            AND provider_gap IN (
                'OK',
                'GAP_NO_FALLBACK_PROVIDER',
                'GAP_NO_WORKER'
            )
            THEN TRUE
            ELSE FALSE
        END AS runtime_ready,

        CASE
            WHEN provider_route_state IN (
                'CONFIRMED_PROVIDER',
                'RUNNABLE_PROVIDER',
                'PARTIAL_PROVIDER'
            )
            AND routing_candidate IS TRUE
            AND resolved_worker_script IS NOT NULL
            AND provider_gap IN (
                'OK',
                'GAP_NO_FALLBACK_PROVIDER',
                'GAP_NO_WORKER'
            )
            THEN 'CAN_RUN_NOW_RUNTIME'

            WHEN provider_route_state IN (
                'PLANNED_PROVIDER'
            )
            THEN 'PLANNED_ONLY'

            WHEN provider_route_state IN (
                'BLOCKED_PROVIDER',
                'BLOCKED_COVERAGE_DISABLED',
                'BLOCKED_PROVIDER_SPORT_DISABLED'
            )
            THEN 'BLOCKED_RUNTIME'

            ELSE 'NOT_RUNTIME_READY'
        END AS runtime_execution_state

    FROM q
)

SELECT
    sport_code,
    sport_name,
    entity,

    primary_provider,
    fallback_provider,
    candidate_provider,
    routing_rank,

    provider_route_state,
    provider_gap,

    execution_state AS audit_execution_state,
    runtime_execution_state,
    runtime_ready,

    automation_ready,
    routing_candidate,

    coverage_status,
    runtime_state,
    sport_completion_status,
    production_readiness,

    run_group,
    resolved_worker_script,

    source_endpoint,
    target_table,
    worker_script,

    limitations,
    key_gap,
    runtime_reason,
    db_evidence_summary,
    next_action,

    last_run_at,

    provider_priority,
    fetch_priority,
    merge_priority,
    priority_rank

FROM r

WHERE runtime_ready IS TRUE

ORDER BY
    sport_code,
    entity,
    routing_rank;