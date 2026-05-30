/*
MATCHMATRIX SQL 106_G V4

Co to je:
SAFE runtime-ready automation queue.

K čemu to je:
Vrací pouze:
- ověřené runtime kandidáty
- bezpečné routy
- scheduler-safe execution queue

Použití:
- future scheduler
- Control Panel RUN NOW
- autonomous orchestration
- retry engine
*/

CREATE OR REPLACE VIEW ops.v_automation_ready_queue_v4 AS

WITH base AS (

    SELECT
        *

    FROM ops.v_automation_ready_queue_v3

),

filtered AS (

    SELECT
        *

    FROM base

    WHERE

        runtime_ready IS TRUE

        /* jen potvrzené / runtime-tested */
        AND (
            coverage_status ILIKE 'confirmed%'
            OR coverage_status ILIKE 'runtime_tested%'
            OR coverage_status ILIKE 'tech_ready%'
            OR provider_route_state IN (
                'CONFIRMED_PROVIDER',
                'RUNNABLE_PROVIDER'
            )
        )

        /* nechceme placeholdery */
        AND candidate_provider NOT IN (
            'api_darts',
            'api_esports'
        )

        /* nechceme fake fallback providers */
        AND candidate_provider NOT IN (
            'sportdataapi',
            'sportradar'
        )

        /* pouze entity které už máme pipeline */
        AND entity IN (
            'fixtures',
            'teams',
            'leagues',
            'players'
        )

        /* pouze sporty s reálnou core vrstvou */
        AND sport_code IN (
            'FB',
            'BK',
            'HK',
            'HB',
            'VB',
            'BSB',
            'CK',
            'AFB',
            'RGB'
        )

        /* musí existovat run_group NEBO core entity */
        AND (
            run_group IS NOT NULL
            OR entity IN (
                'fixtures',
                'teams',
                'leagues'
            )
        )

        /* bezpečné worker routy */
        AND resolved_worker_script IN (
            'workers/run_ingest_cycle_v3.py',
            'workers/run_people_pipeline_v22_from_planner.py',
            'workers/run_media_pipeline_v1.py'
        )

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

    source_endpoint,
    target_table,

    last_run_at,

    next_action,

    provider_priority,
    fetch_priority,
    merge_priority,

    routing_rank

FROM filtered

ORDER BY
    sport_code,
    entity,
    routing_rank;