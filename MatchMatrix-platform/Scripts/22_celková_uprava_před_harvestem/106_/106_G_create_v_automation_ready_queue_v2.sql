/*
MATCHMATRIX SQL 106_G V2

Co to je:
Pragmatic automation-ready queue.

K čemu to je:
Vrací reálně spustitelné položky i tehdy, když ve view chybí explicitní worker_script,
protože panel/launcher umí core entity pustit přes default worker:
workers/run_ingest_cycle_v3.py
*/

CREATE OR REPLACE VIEW ops.v_automation_ready_queue_v2 AS

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

WHERE
    routing_candidate IS TRUE

    AND provider_route_state IN (
        'CONFIRMED_PROVIDER',
        'RUNNABLE_PROVIDER',
        'PARTIAL_PROVIDER'
    )

    AND execution_state IN (
        'CAN_RUN_NOW',
        'BLOCKED_PROVIDER',
        'NOT_AUTOMATION_READY',
        'FAILOVER_READY'
    )

    AND entity IN (
        'fixtures',
        'teams',
        'leagues',
        'players',
        'coaches',
        'player_stats',
        'player_season_stats',
        'articles',
        'media',
        'highlights'
    )

ORDER BY
    sport_code,
    entity,
    routing_rank;