/*
MATCHMATRIX SQL 108_R
Unified Worker Registry V1

CO TO JE:
- Centrální registry všech workerů a orchestration flow.

K ČEMU TO JE:
- Panel a scheduler budou vědět:
  - který worker co obsluhuje
  - jaký parser se používá
  - jaký merge flow existuje
  - zda je flow unified nebo legacy

KDE TO UVIDÍME:
- ops.unified_worker_registry
- panel V18+

JAK SE TO VYUŽIJE:
- orchestration governance
- runtime monitoring
- scheduler intelligence
- migration management
- provider governance
*/

CREATE TABLE IF NOT EXISTS ops.unified_worker_registry
(
    id BIGSERIAL PRIMARY KEY,

    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    entity TEXT NOT NULL,

    pull_worker TEXT,
    parse_worker TEXT,
    merge_worker TEXT,

    source_table TEXT,
    target_table TEXT,

    flow_type TEXT,
    orchestration_layer TEXT,

    runtime_ready BOOLEAN DEFAULT false,
    panel_ready BOOLEAN DEFAULT false,
    scheduler_ready BOOLEAN DEFAULT false,

    migration_state TEXT DEFAULT 'REVIEW',

    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_unified_worker_registry_main
ON ops.unified_worker_registry
(
    provider,
    sport_code,
    entity
);