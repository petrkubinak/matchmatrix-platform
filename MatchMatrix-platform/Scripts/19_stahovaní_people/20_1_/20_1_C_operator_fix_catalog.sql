/*
===============================================================================
MATCHMATRIX 20_1_C – OPERATOR FIX CATALOG
===============================================================================

CO TO JE:
Katalog standardních oprav pro operátorský panel DENNÍ PRÁCE.

K ČEMU TO JE:
Panel už umí poznat chybu běhu harvestu.
Tento katalog mu řekne, jakou opravu má nabídnout operátorovi.

KDE TO UVIDÍME:
OPS Panel
→ DENNÍ PRÁCE
→ CHYBY / STOP
→ DOPORUČENÁ OPRAVA

Databáze:
ops.operator_fix_catalog

JAK SE TO VYUŽIJE:
Chyby jako TIMEOUT, 429, ROUTING_ERROR nebo WORKER_DEAD
se převedou na srozumitelné návrhy:
- retry
- počkat
- reset na READY
- ověřit worker
- ruční kontrola

NAVAZUJE NA:
20_1_A_harvest_run_monitor.sql
20_1_B_harvest_run_monitor_views.sql

DALŠÍ KROK:
20_1_D_operator_fix_recommendations.sql
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.operator_fix_catalog
(
    fix_id BIGSERIAL PRIMARY KEY,

    error_code TEXT NOT NULL,
    error_pattern TEXT,
    fix_code TEXT NOT NULL,

    fix_title_cz TEXT NOT NULL,
    fix_description_cz TEXT NOT NULL,
    operator_button_cz TEXT NOT NULL,

    risk_level TEXT NOT NULL DEFAULT 'LOW',
    confidence_pct NUMERIC(5,2) NOT NULL DEFAULT 80.00,

    auto_executable BOOLEAN NOT NULL DEFAULT false,
    requires_operator_confirm BOOLEAN NOT NULL DEFAULT true,

    target_table TEXT,
    target_action TEXT,

    is_active BOOLEAN NOT NULL DEFAULT true,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_operator_fix_catalog_code UNIQUE (error_code, fix_code)
);

CREATE INDEX IF NOT EXISTS idx_operator_fix_catalog_error_code
ON ops.operator_fix_catalog(error_code);

CREATE INDEX IF NOT EXISTS idx_operator_fix_catalog_active
ON ops.operator_fix_catalog(is_active);

INSERT INTO ops.operator_fix_catalog
(
    error_code,
    error_pattern,
    fix_code,
    fix_title_cz,
    fix_description_cz,
    operator_button_cz,
    risk_level,
    confidence_pct,
    auto_executable,
    requires_operator_confirm,
    target_table,
    target_action
)
VALUES
(
    'TIMEOUT',
    '%TIMEOUT%',
    'RETRY_READY',
    'Opakovat běh',
    'Provider neodpověděl v časovém limitu. Nejbezpečnější oprava je vrátit běh do READY a spustit znovu.',
    'OPAKOVAT',
    'LOW',
    90.00,
    true,
    true,
    'ops.pc2_run_command_queue',
    'SET_READY'
),
(
    '429',
    '%429%',
    'WAIT_AND_RETRY',
    'Počkat a opakovat',
    'Provider hlásí rate limit. Doporučení je počkat a potom běh znovu spustit.',
    'POČKAT / RETRY',
    'LOW',
    85.00,
    false,
    true,
    'ops.pc2_run_command_queue',
    'WAIT_THEN_SET_READY'
),
(
    'RATE_LIMIT_429',
    '%RATE_LIMIT%',
    'WAIT_AND_RETRY',
    'Počkat kvůli limitu',
    'Byl dosažen API limit. Nepouštěj hned další běh, nejdříve počkej podle limitu providera.',
    'POČKAT',
    'LOW',
    85.00,
    false,
    true,
    'ops.pc2_run_command_queue',
    'WAIT_THEN_SET_READY'
),
(
    'ROUTING_ERROR',
    '%ROUTING%',
    'RESET_COMMAND_READY',
    'Resetovat příkaz',
    'Chyba routování znamená, že příkaz nebyl správně nasměrován na worker. Doporučení je ověřit worker a resetovat příkaz.',
    'RESETOVAT',
    'MEDIUM',
    75.00,
    true,
    true,
    'ops.pc2_run_command_queue',
    'SET_READY'
),
(
    'WORKER_DEAD',
    '%WORKER%',
    'VERIFY_WORKER',
    'Ověřit worker',
    'Worker pravděpodobně neběží nebo nereaguje. Nejdříve ověř worker, potom spusť retry.',
    'OVĚŘIT WORKER',
    'MEDIUM',
    70.00,
    false,
    true,
    'ops.active_worker_runs',
    'VERIFY_WORKER'
),
(
    'PENDING_LOCK',
    '%LOCK%',
    'CHECK_LOCK',
    'Zkontrolovat lock',
    'Běh může být blokovaný zámkem. Doporučení je ověřit aktivní běhy a zámek neuvolňovat bez kontroly.',
    'ZKONTROLOVAT',
    'MEDIUM',
    65.00,
    false,
    true,
    'ops.active_worker_runs',
    'CHECK_LOCK'
),
(
    'EMPTY_RESPONSE',
    '%EMPTY%',
    'VERIFY_PROVIDER_RESPONSE',
    'Ověřit odpověď providera',
    'Provider vrátil prázdnou odpověď. Může jít o chybějící data, špatný endpoint nebo limit.',
    'OVĚŘIT',
    'LOW',
    70.00,
    false,
    true,
    'ops.api_request_log',
    'VERIFY_RESPONSE'
),
(
    'PARSER_ERROR',
    '%PARSER%',
    'CHECK_PARSER',
    'Zkontrolovat parser',
    'Data přišla, ale parser je neuměl zpracovat. Je potřeba otevřít log a upravit parser.',
    'OTEVŘÍT LOG',
    'HIGH',
    60.00,
    false,
    true,
    'ops.runtime_execution_history',
    'OPEN_LOG'
)
ON CONFLICT (error_code, fix_code) DO UPDATE
SET
    error_pattern = EXCLUDED.error_pattern,
    fix_title_cz = EXCLUDED.fix_title_cz,
    fix_description_cz = EXCLUDED.fix_description_cz,
    operator_button_cz = EXCLUDED.operator_button_cz,
    risk_level = EXCLUDED.risk_level,
    confidence_pct = EXCLUDED.confidence_pct,
    auto_executable = EXCLUDED.auto_executable,
    requires_operator_confirm = EXCLUDED.requires_operator_confirm,
    target_table = EXCLUDED.target_table,
    target_action = EXCLUDED.target_action,
    is_active = true,
    updated_at = now();