/*
===============================================================================
MATCHMATRIX 20_1_E – OPERATOR FIX EXECUTION LOG
===============================================================================

CO TO JE:
Auditní tabulka pro všechny opravy provedené z operátorského panelu DENNÍ PRÁCE.

K ČEMU TO JE:
Každé kliknutí na budoucí tlačítko OPRAVIT bude zapsané do logu:
- jaká chyba se opravovala
- jaká oprava byla doporučená
- kdo opravu spustil
- kdy byla spuštěná
- jaký byl výsledek

KDE TO UVIDÍME:
OPS Panel
→ DENNÍ PRÁCE
→ CHYBY / STOP
→ HISTORIE OPRAV

Databáze:
ops.operator_fix_execution_log

JAK SE TO VYUŽIJE:
Později budeme z této tabulky počítat úspěšnost oprav:
TIMEOUT → kolikrát pomohlo RETRY
ROUTING_ERROR → kolikrát pomohl reset
WORKER_DEAD → kolikrát bylo nutné ruční řešení

NAVAZUJE NA:
20_1_A_harvest_run_monitor.sql
20_1_B_harvest_run_monitor_views.sql
20_1_C_operator_fix_catalog.sql
20_1_D_operator_fix_recommendations.sql

DALŠÍ KROK:
20_1_F_operator_auto_fix_engine.sql
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.operator_fix_execution_log
(
    fix_execution_id BIGSERIAL PRIMARY KEY,

    -- Vazba na monitor chyby
    monitor_id BIGINT,
    run_key TEXT,

    -- Vazba na katalog oprav
    fix_id BIGINT,
    fix_code TEXT,
    error_code TEXT,

    -- Kontext běhu
    sport_code TEXT,
    sport_name TEXT,
    provider TEXT,
    entity_type TEXT,
    target_layer TEXT,

    -- Co se spouštělo
    target_table TEXT,
    target_action TEXT,

    -- Operátor / režim
    executed_by TEXT NOT NULL DEFAULT 'PANEL_OPERATOR',
    execution_mode TEXT NOT NULL DEFAULT 'MANUAL_CONFIRM',

    -- Stav opravy
    execution_status TEXT NOT NULL DEFAULT 'PENDING',
    execution_result TEXT,
    execution_message TEXT,

    -- Čas
    requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,

    -- Audit
    before_state JSONB,
    after_state JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_operator_fix_execution_log_monitor
ON ops.operator_fix_execution_log(monitor_id);

CREATE INDEX IF NOT EXISTS idx_operator_fix_execution_log_status
ON ops.operator_fix_execution_log(execution_status);

CREATE INDEX IF NOT EXISTS idx_operator_fix_execution_log_fix_code
ON ops.operator_fix_execution_log(fix_code);

CREATE INDEX IF NOT EXISTS idx_operator_fix_execution_log_requested_at
ON ops.operator_fix_execution_log(requested_at DESC);