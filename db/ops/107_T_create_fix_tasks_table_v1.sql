/*
MATCHMATRIX SQL 107_T CREATE FIX TASKS TABLE V1

CO TO JE:
- Centrální tabulka pro automaticky zachycené FIX úkoly z panelu.

K ČEMU TO JE:
- Ukládání parser problémů, duplicate key chyb,
  scheduler warningů a dalších technických problémů.

KDE TO UVIDÍME:
- Budoucí záložka FIX TASKS v MATCHMATRIX OPERATIONS CENTER.

JAK SE TO VYUŽIJE:
- evidence problémů
- retry/fix workflow
- AI doporučení oprav
- priorita kritických bugů
*/

CREATE TABLE IF NOT EXISTS ops.fix_tasks (
    id BIGSERIAL PRIMARY KEY,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    provider TEXT,
    sport_code TEXT,
    entity_type TEXT,
    endpoint_name TEXT,

    parse_status TEXT,

    severity TEXT DEFAULT 'warning',

    short_message TEXT,
    full_message TEXT,

    suggested_fix TEXT,

    task_status TEXT DEFAULT 'open',

    source_payload_id BIGINT,

    created_by TEXT DEFAULT 'control_panel'
);

CREATE INDEX IF NOT EXISTS idx_fix_tasks_created_at
ON ops.fix_tasks(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_fix_tasks_status
ON ops.fix_tasks(task_status);

CREATE INDEX IF NOT EXISTS idx_fix_tasks_provider
ON ops.fix_tasks(provider);

CREATE INDEX IF NOT EXISTS idx_fix_tasks_entity
ON ops.fix_tasks(entity_type);