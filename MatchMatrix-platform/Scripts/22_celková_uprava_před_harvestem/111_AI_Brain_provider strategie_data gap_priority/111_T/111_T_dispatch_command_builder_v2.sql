/*
MATCHMATRIX SQL 111_T

DISPATCH COMMAND BUILDER V1

CO TO JE:
- Připraví spouštěcí příkaz pro SELECTED akci.

K ČEMU TO JE:
- Oddělení rozhodnutí od samotného spuštění.
- Dispatcher připraví command.
- Budoucí launcher command vykoná.

KDE TO UVIDÍME:
- View ops.v_dispatch_ready_commands_v1

JAK SE TO VYUŽIJE:
Brain
 ↓
Dispatch Queue
 ↓
SELECTED
 ↓
Command Builder
 ↓
READY COMMAND
 ↓
Launcher
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

        WHEN q.entity = 'players'
        THEN
            'C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_ingest_planner_jobs.py ' ||
            '--provider "' || COALESCE(q.provider,'') || '" ' ||
            '--sport "' || COALESCE(q.sport_code,'') || '" ' ||
            '--entity "players" ' ||
            '--season "' || COALESCE(q.season,'') || '"'

        WHEN q.entity = 'fixtures'
        THEN
            'C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_ingest_planner_jobs.py ' ||
            '--provider "' || COALESCE(q.provider,'') || '" ' ||
            '--sport "' || COALESCE(q.sport_code,'') || '" ' ||
            '--entity "fixtures"'

        WHEN q.entity = 'teams'
        THEN
            'C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_ingest_planner_jobs.py ' ||
            '--provider "' || COALESCE(q.provider,'') || '" ' ||
            '--sport "' || COALESCE(q.sport_code,'') || '" ' ||
            '--entity "teams"'

        ELSE
            'MANUAL_REVIEW_REQUIRED'

    END AS worker_command,

    'READY_TO_RUN' AS command_status,

    NOW() AS generated_at

FROM ops.dispatch_queue q

WHERE q.dispatch_status = 'SELECTED';