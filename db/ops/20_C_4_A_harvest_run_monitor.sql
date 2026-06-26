/*
===============================================================================
MATCHMATRIX 20_C_4_A – HARVEST RUN MONITOR
===============================================================================

CO TO JE:
Operační tabulka pro živé sledování průběhu harvestů a backfillů.

K ČEMU TO JE:
Umožní panelu DENNÍ PRÁCE zobrazovat grafický průběh běhu:
- procenta dokončení
- počet zpracovaných položek
- počet nových / aktualizovaných / přeskočených záznamů
- počet chyb
- ETA
- poslední heartbeat

KDE TO UVIDÍME:
OPS Panel
→ DENNÍ PRÁCE
→ AKTUÁLNÍ BĚH
→ PRŮBĚH / VÝSLEDEK / CHYBY

Databáze:
ops.harvest_run_monitor

JAK SE TO VYUŽIJE:
Workery budou při spuštění zapisovat START,
během práce průběžně RUNNING,
při dokončení DONE,
při chybě ERROR.

NAVAZUJE NA:
20_C_2 Visual Operator Cards
20_C_3 Visual Operator Dashboard

DALŠÍ KROK:
20_C_4_B Harvest Run Monitor Views
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.harvest_run_monitor
(
    monitor_id BIGSERIAL PRIMARY KEY,

    -- Vazba na existující PC2 / worker systém
    command_id BIGINT,
    pc2_execution_history_id BIGINT,
    job_run_id BIGINT,

    -- Identifikace běhu
    run_key TEXT,
    run_group TEXT,
    worker_name TEXT,
    worker_script TEXT,
    command_text TEXT,

    -- Doména
    sport_code TEXT,
    sport_name TEXT,
    provider TEXT,
    entity_type TEXT,
    target_layer TEXT,
    season_from INTEGER,
    season_to INTEGER,
    current_season INTEGER,

    -- Stav běhu
    run_status TEXT NOT NULL DEFAULT 'READY',
    run_status_cz TEXT,

    -- Čas
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    started_at TIMESTAMPTZ,
    last_heartbeat_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,

    -- Progress
    total_count BIGINT DEFAULT 0,
    processed_count BIGINT DEFAULT 0,
    inserted_count BIGINT DEFAULT 0,
    updated_count BIGINT DEFAULT 0,
    skipped_count BIGINT DEFAULT 0,
    error_count BIGINT DEFAULT 0,

    progress_pct NUMERIC(6,2) DEFAULT 0,
    eta_seconds BIGINT,

    -- Výsledek / chyba
    return_code INTEGER,
    last_error_code TEXT,
    last_error_message TEXT,
    result_message TEXT,
    operator_recommendation TEXT,

    -- Technický audit
    source_system TEXT DEFAULT 'MATCHMATRIX_PANEL',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_harvest_run_monitor_status
ON ops.harvest_run_monitor(run_status);

CREATE INDEX IF NOT EXISTS idx_harvest_run_monitor_command_id
ON ops.harvest_run_monitor(command_id);

CREATE INDEX IF NOT EXISTS idx_harvest_run_monitor_started_at
ON ops.harvest_run_monitor(started_at DESC);

CREATE INDEX IF NOT EXISTS idx_harvest_run_monitor_sport_entity
ON ops.harvest_run_monitor(sport_code, entity_type);