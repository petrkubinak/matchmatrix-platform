/*
MATCHMATRIX SQL 107_A
Create worker registry table V1

CO TO JE:
- Centrální registr workerů pro MatchMatrix.
- Tabulka říká, které workery existují, kde jsou uložené a jestli je smí spouštět scheduler/panel.
- Slouží jako zdroj pravdy pro bezpečné runtime spouštění.

K ČEMU TO JE:
- Aby scheduler nespouštěl neexistující, testovací, legacy nebo unsafe workery.
- Aby panel věděl, který worker je runtime-ready.
- Aby bylo možné řídit retry, timeout, paralelní běh a production-safe stav.

NA CO TO BUDE:
- SAFE SCHEDULER V17.1+
- RUN NEXT engine
- automation runner
- runtime governance
- worker health audit
- budoucí autonomous mode

KDE TO POUŽIJEME:
- ops.worker_registry
- ops.v_automation_ready_queue_v4
- ops.v_execution_priority_queue_v1
- budoucí worker resolver view
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17.py
*/

CREATE SCHEMA IF NOT EXISTS ops;

CREATE TABLE IF NOT EXISTS ops.worker_registry (
    id BIGSERIAL PRIMARY KEY,

    worker_code TEXT NOT NULL,
    worker_name TEXT NOT NULL,

    worker_script TEXT NOT NULL,
    worker_type TEXT NOT NULL DEFAULT 'python',

    sport_code TEXT,
    entity TEXT,

    layer_code TEXT NOT NULL DEFAULT 'core',

    supports_scheduler BOOLEAN NOT NULL DEFAULT false,
    supports_retry BOOLEAN NOT NULL DEFAULT true,
    supports_parallel BOOLEAN NOT NULL DEFAULT false,

    timeout_sec INTEGER NOT NULL DEFAULT 300,
    max_attempts INTEGER NOT NULL DEFAULT 3,

    is_enabled BOOLEAN NOT NULL DEFAULT true,
    is_production_safe BOOLEAN NOT NULL DEFAULT false,

    worker_status TEXT NOT NULL DEFAULT 'planned',

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_worker_registry_code UNIQUE (worker_code),

    CONSTRAINT chk_worker_registry_status CHECK (
        worker_status IN (
            'planned',
            'implemented',
            'runtime_tested',
            'production_ready',
            'disabled',
            'deprecated',
            'broken'
        )
    ),

    CONSTRAINT chk_worker_registry_layer CHECK (
        layer_code IN (
            'core',
            'people',
            'media',
            'odds',
            'admin',
            'orchestration'
        )
    )
);

CREATE INDEX IF NOT EXISTS ix_worker_registry_lookup
ON ops.worker_registry (sport_code, entity, is_enabled, is_production_safe);

CREATE INDEX IF NOT EXISTS ix_worker_registry_script
ON ops.worker_registry (worker_script);

COMMENT ON TABLE ops.worker_registry IS
'Central registry of workers allowed for MatchMatrix scheduler, panel execution, retry engine and autonomous orchestration.';