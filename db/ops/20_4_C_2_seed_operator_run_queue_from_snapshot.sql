/*
MATCHMATRIX SCRIPT

NÁZEV:
20_4_C_2_seed_operator_run_queue_from_snapshot.sql

CO TO JE:
Naplnění Operator Run Queue z aktuálního harvest snapshotu.

K ČEMU TO JE:
Z rychlého snapshotu vytvoří konkrétní akce ke spuštění na PC2.

KDE TO UVIDÍME:
OPS Panel → Denní práce → Harvest Command Center.

JAK SE TO VYUŽIJE:
PC1 panel uvidí READY akce.
PC2 bude vykonávat harvest workery.
*/

INSERT INTO ops.operator_run_queue
(
    created_by,
    control_host,
    data_host,
    execution_mode,

    sport_code,
    sport_name,
    run_layer,
    harvest_priority,

    worker_name,
    worker_script,
    command_text,

    status,
    progress_pct,

    operator_action_cz,
    operator_note_cz,

    is_active
)
SELECT
    'SNAPSHOT_SEED',
    'PC1',
    'PC2',
    'REMOTE_PC2',

    h.sport_code,
    h.sport_name,
    h.next_layer_step,
    h.harvest_priority,

    CASE
        WHEN h.next_layer_step = 'HISTORICAL_CORE'
            THEN 'CORE_HISTORICAL_HARVEST'
        ELSE 'UNKNOWN_WORKER'
    END AS worker_name,

    CASE
        WHEN h.next_layer_step = 'HISTORICAL_CORE'
            THEN 'workers/run_ingest_planner_jobs.py'
        ELSE NULL
    END AS worker_script,

    CASE
        WHEN h.next_layer_step = 'HISTORICAL_CORE'
            THEN 'C:\Python314\python.exe workers\run_ingest_planner_jobs.py --sport '
                 || h.sport_code ||
                 ' --entity fixtures --mode historical --run-group HISTORICAL_CORE_'
                 || h.sport_code
        ELSE NULL
    END AS command_text,

    'READY',
    0,

    h.operator_action_cz,
    h.operator_note_cz,

    true

FROM ops.v_harvest_readiness_current h
WHERE h.final_harvest_status = 'HARVEST_READY'
  AND h.next_layer_step = 'HISTORICAL_CORE'
  AND NOT EXISTS (
      SELECT 1
      FROM ops.operator_run_queue q
      WHERE q.sport_code = h.sport_code
        AND q.run_layer = h.next_layer_step
        AND q.status IN ('READY', 'RUNNING', 'DONE')
        AND q.is_active = true
  )
ORDER BY h.harvest_priority;