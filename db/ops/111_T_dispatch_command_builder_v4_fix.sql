/*
MATCHMATRIX SQL 111_T
DISPATCH COMMAND BUILDER V4 FIX

CO TO JE:
- Bezpečná oprava command builderu.
- Zachovává původní strukturu view ops.v_dispatch_ready_commands_v1.

K ČEMU TO JE:
- PostgreSQL nedovolil změnit názvy/pořadí sloupců přes CREATE OR REPLACE VIEW.
- Registry se použije bez změny výstupních sloupců.

KDE TO UVIDÍME:
- ops.v_dispatch_ready_commands_v1
*/

CREATE OR REPLACE VIEW ops.v_dispatch_ready_commands_v1 AS
SELECT
    q.id AS dispatch_id,
    q.provider,
    q.sport_code,
    q.entity,
    q.league_id,
    q.season,
    q.run_group,
    q.brain_rank,
    q.brain_score,

    CASE
        WHEN r.worker_type = 'UNIFIED_INGEST'
            THEN
                'C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_ingest_planner_jobs.py ' ||
                '--run-group "' || COALESCE(q.run_group, '') || '" ' ||
                '--limit 1 --timeout-sec 300 --max-attempts 3'

        WHEN r.worker_type = 'CUSTOM_WORKER'
            THEN
                'MANUAL_REVIEW_REQUIRED_CUSTOM_WORKER: ' || COALESCE(r.notes, '')

        WHEN r.worker_type = 'NOT_IMPLEMENTED'
            THEN
                'BLOCKED_NOT_IMPLEMENTED: ' || COALESCE(r.notes, '')

        ELSE
            'BLOCKED_NO_WORKER_REGISTRY'
    END AS worker_command,

    CASE
        WHEN r.worker_type = 'UNIFIED_INGEST'
            THEN 'READY_TO_RUN'
        WHEN r.worker_type = 'CUSTOM_WORKER'
            THEN 'MANUAL_REVIEW_REQUIRED'
        WHEN r.worker_type = 'NOT_IMPLEMENTED'
            THEN 'BLOCKED'
        ELSE 'BLOCKED'
    END AS command_status,

    NOW() AS generated_at

FROM ops.dispatch_queue q
LEFT JOIN ops.provider_worker_registry r
    ON r.provider = q.provider
   AND r.sport_code = q.sport_code
   AND r.entity = q.entity
   AND r.is_active = true
WHERE q.dispatch_status IN ('SELECTED', 'PENDING');