/*
MATCHMATRIX SCRIPT

NÁZEV:
20_4_C_1_create_operator_run_queue_pc2_first.sql

CO TO JE:
Fronta spuštění pro Harvest Command Center.

K ČEMU TO JE:
Panel na PC1 bude řídit běhy na PC2.

KDE TO UVIDÍME:
OPS Panel
Denní práce
Harvest Command Center

JAK SE TO VYUŽIJE:
PC1:
- vybere akci
- odešle příkaz

PC2:
- vykoná worker
- zapíše stav
- vrátí výsledek

ARCHITEKTURA:
PC1 = CONTROL HOST
PC2 = DATA HOST
*/

CREATE TABLE IF NOT EXISTS ops.operator_run_queue (

    run_id bigserial PRIMARY KEY,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    created_by text DEFAULT 'OPERATOR_PANEL',

    control_host text NOT NULL DEFAULT 'PC1',
    data_host text NOT NULL DEFAULT 'PC2',

    execution_mode text NOT NULL DEFAULT 'REMOTE_PC2',

    sport_code text NOT NULL,
    sport_name text,

    run_layer text NOT NULL,

    /*
    HISTORICAL_CORE
    CURRENT_CORE
    PEOPLE
    MEDIA
    ODDS
    */

    harvest_priority integer DEFAULT 999,

    worker_name text,
    worker_script text,

    command_text text,

    planner_id bigint,

    status text NOT NULL DEFAULT 'READY',

    /*
    READY
    RUNNING
    DONE
    FAILED
    CANCELLED
    */

    started_at timestamptz,
    finished_at timestamptz,

    progress_pct numeric(5,2) DEFAULT 0,

    rows_processed bigint DEFAULT 0,
    rows_inserted bigint DEFAULT 0,
    rows_updated bigint DEFAULT 0,
    rows_failed bigint DEFAULT 0,

    result_code text,
    result_message text,

    operator_action_cz text,
    operator_note_cz text,

    last_error_code text,
    last_error_message text,

    retry_count integer DEFAULT 0,

    is_active boolean NOT NULL DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_operator_run_queue_status
ON ops.operator_run_queue (
    status,
    harvest_priority
);

CREATE INDEX IF NOT EXISTS idx_operator_run_queue_sport
ON ops.operator_run_queue (
    sport_code,
    run_layer
);

CREATE INDEX IF NOT EXISTS idx_operator_run_queue_active
ON ops.operator_run_queue (
    is_active,
    status
);