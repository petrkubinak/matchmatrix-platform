/*
MATCHMATRIX SQL 111_T
DISPATCH COMMAND BUILDER V3

CO TO JE:
- Opravuje command builder na run_group režim.

K ČEMU TO JE:
- run_ingest_planner_jobs.py nepodporuje --season.
- Planner má parametry už v DB.
- Dispatcher má spouštět podle run_group.

KDE TO UVIDÍME:
- ops.v_dispatch_ready_commands_v1

JAK SE TO VYUŽIJE:
- Budoucí launcher vezme worker_command a spustí ho.
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

    'C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_ingest_planner_jobs.py ' ||
    '--run-group "' || COALESCE(q.run_group, '') || '" ' ||
    '--limit 1 --timeout-sec 300 --max-attempts 3'
    AS worker_command,

    'READY_TO_RUN' AS command_status,
    NOW() AS generated_at
FROM ops.dispatch_queue q
WHERE q.dispatch_status = 'SELECTED';