/*
MATCHMATRIX SQL 19_3_D
PC2 Run Command Queue V1

CO TO JE:
- Připraví konkrétní spouštěcí frontu pro PC2 harvest.
- Každý řádek obsahuje sport, vrstvu, prioritu, příkaz a stav.

K ČEMU TO JE:
- Aby panel V18 mohl zobrazit konkrétní příkaz ke spuštění.
- Aby uživatel viděl, co přesně se má spustit.
- Aby později šlo přejít z ručního spuštění na automatické.

KDE TO UVIDÍME:
- OPS Panel V18
- PC2 Command Center
- Harvest Queue

JAK SE TO VYUŽIJE:
- Panel zobrazí připravený příkaz.
- Tlačítko RUN ho později spustí.
- Výsledek se zapíše do runtime logu.
*/

-- =====================================================
-- 1) TABULKA PC2 RUN COMMAND QUEUE
-- =====================================================

CREATE TABLE IF NOT EXISTS ops.pc2_run_command_queue (
    id BIGSERIAL PRIMARY KEY,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    sport_code TEXT NOT NULL,
    sport_name TEXT,

    target_layer TEXT NOT NULL,
    execution_bucket TEXT,

    priority_score INTEGER NOT NULL DEFAULT 100,

    command_title TEXT NOT NULL,
    command_text TEXT NOT NULL,

    run_status TEXT NOT NULL DEFAULT 'READY_TO_RUN',

    run_group TEXT,
    worker_name TEXT,
    worker_script TEXT,

    safety_mode TEXT NOT NULL DEFAULT 'MANUAL_CONFIRM',

    panel_visible BOOLEAN NOT NULL DEFAULT true,
    panel_action_enabled BOOLEAN NOT NULL DEFAULT true,

    last_started_at TIMESTAMPTZ,
    last_finished_at TIMESTAMPTZ,
    last_result TEXT,

    notes TEXT,

    CONSTRAINT pc2_run_command_queue_status_chk CHECK (
        run_status IN (
            'READY_TO_RUN',
            'RUNNING',
            'DONE',
            'FAILED',
            'BLOCKED',
            'DISABLED'
        )
    ),

    CONSTRAINT pc2_run_command_queue_safety_chk CHECK (
        safety_mode IN (
            'MANUAL_CONFIRM',
            'AUTO_ALLOWED',
            'AUTO_DISABLED'
        )
    ),

    CONSTRAINT pc2_run_command_queue_unique UNIQUE (
        sport_code,
        target_layer,
        run_group
    )
);


-- =====================================================
-- 2) VYČIŠTĚNÍ STARÝCH READY ŘÁDKŮ PRO 19_3_D
-- =====================================================

DELETE FROM ops.pc2_run_command_queue
WHERE run_group = '19_3_PC2_DEPENDENCY_QUEUE'
  AND run_status = 'READY_TO_RUN';


-- =====================================================
-- 3) SEED KONKRÉTNÍCH PŘÍKAZŮ PODLE ROADMAPY
-- =====================================================

INSERT INTO ops.pc2_run_command_queue
(
    sport_code,
    sport_name,
    target_layer,
    execution_bucket,
    priority_score,
    command_title,
    command_text,
    run_status,
    run_group,
    worker_name,
    worker_script,
    safety_mode,
    panel_visible,
    panel_action_enabled,
    notes
)
SELECT
    sport_code,
    sport_name,
    next_harvest_layer,
    roadmap_bucket,

    CASE
        WHEN next_harvest_layer = 'CORE' THEN 10
        WHEN next_harvest_layer = 'PEOPLE' THEN 20
        WHEN next_harvest_layer = 'MEDIA' THEN 30
        WHEN next_harvest_layer = 'ODDS' THEN 40
        ELSE 90
    END AS priority_score,

    CASE
        WHEN next_harvest_layer = 'CORE'
            THEN 'Spustit CORE harvest pro ' || sport_code
        WHEN next_harvest_layer = 'PEOPLE'
            THEN 'Spustit PEOPLE harvest pro ' || sport_code
        WHEN next_harvest_layer = 'MEDIA'
            THEN 'Spustit MEDIA harvest pro ' || sport_code
        WHEN next_harvest_layer = 'ODDS'
            THEN 'Spustit ODDS harvest pro ' || sport_code
        ELSE 'Připraveno pro CONTEXT ' || sport_code
    END AS command_title,

    CASE
        WHEN next_harvest_layer = 'CORE'
            THEN 'python workers/run_ingest_planner_jobs.py --sport ' || sport_code || ' --layer core --run-group PC2_CORE_' || sport_code

        WHEN next_harvest_layer = 'PEOPLE'
            THEN 'python workers/run_ingest_planner_jobs.py --sport ' || sport_code || ' --layer people --run-group PC2_PEOPLE_' || sport_code

        WHEN next_harvest_layer = 'MEDIA'
            THEN 'python workers/run_ingest_planner_jobs.py --sport ' || sport_code || ' --layer media --run-group PC2_MEDIA_' || sport_code

        WHEN next_harvest_layer = 'ODDS'
            THEN 'python workers/run_ingest_planner_jobs.py --sport ' || sport_code || ' --layer odds --run-group PC2_ODDS_' || sport_code

        ELSE 'echo CONTEXT_READY_' || sport_code
    END AS command_text,

    'READY_TO_RUN' AS run_status,
    '19_3_PC2_DEPENDENCY_QUEUE' AS run_group,

    'run_ingest_planner_jobs' AS worker_name,
    'workers/run_ingest_planner_jobs.py' AS worker_script,

    'MANUAL_CONFIRM' AS safety_mode,

    true AS panel_visible,
    true AS panel_action_enabled,

    pc2_next_action_cs AS notes

FROM ops.v_pc2_master_harvest_roadmap_v1
WHERE next_harvest_layer IN ('CORE','PEOPLE','MEDIA','ODDS')
ON CONFLICT (sport_code, target_layer, run_group)
DO UPDATE SET
    sport_name = EXCLUDED.sport_name,
    execution_bucket = EXCLUDED.execution_bucket,
    priority_score = EXCLUDED.priority_score,
    command_title = EXCLUDED.command_title,
    command_text = EXCLUDED.command_text,
    run_status = 'READY_TO_RUN',
    worker_name = EXCLUDED.worker_name,
    worker_script = EXCLUDED.worker_script,
    safety_mode = EXCLUDED.safety_mode,
    panel_visible = true,
    panel_action_enabled = true,
    notes = EXCLUDED.notes,
    updated_at = now();


-- =====================================================
-- 4) VIEW PRO PANEL
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_run_command_queue_v1 AS
SELECT
    id,
    sport_code,
    sport_name,
    target_layer,
    execution_bucket,
    priority_score,
    command_title,
    command_text,
    run_status,
    safety_mode,
    panel_visible,
    panel_action_enabled,
    worker_name,
    worker_script,
    run_group,
    notes,
    last_started_at,
    last_finished_at,
    last_result,
    updated_at
FROM ops.pc2_run_command_queue
WHERE panel_visible = true
ORDER BY
    priority_score,
    sport_code,
    target_layer;


-- =====================================================
-- 5) NEXT COMMAND PRO PANEL BUTTON
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_next_run_command_v1 AS
SELECT *
FROM ops.v_pc2_run_command_queue_v1
WHERE run_status = 'READY_TO_RUN'
  AND panel_action_enabled = true
ORDER BY
    priority_score,
    sport_code,
    target_layer
LIMIT 1;


-- =====================================================
-- 6) SUMMARY
-- =====================================================

CREATE OR REPLACE VIEW ops.v_pc2_run_command_queue_summary_v1 AS
SELECT
    run_status,
    target_layer,
    COUNT(*) AS command_count
FROM ops.pc2_run_command_queue
GROUP BY
    run_status,
    target_layer
ORDER BY
    run_status,
    target_layer;


-- =====================================================
-- 7) QUICK CHECK
-- =====================================================

SELECT
    target_layer,
    run_status,
    COUNT(*) AS command_count
FROM ops.v_pc2_run_command_queue_v1
GROUP BY
    target_layer,
    run_status
ORDER BY
    target_layer,
    run_status;