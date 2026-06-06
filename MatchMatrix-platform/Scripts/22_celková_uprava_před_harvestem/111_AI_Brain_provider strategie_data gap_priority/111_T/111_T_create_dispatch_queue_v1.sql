/*
MATCHMATRIX SQL 111_T

AUTONOMOUS DISPATCH QUEUE V1

CO TO JE:
- Fronta akcí připravených k dispatchi.

K ČEMU TO JE:
- Odděluje Brain od Dispatcheru.
- Brain doporučuje.
- Dispatcher vykonává.

KDE TO UVIDÍME:
- AI OPS panel
- Dispatcher panel

JAK SE TO VYUŽIJE:
Brain
 ↓
dispatch_queue
 ↓
dispatcher
 ↓
worker
*/

CREATE TABLE IF NOT EXISTS ops.dispatch_queue (

    id BIGSERIAL PRIMARY KEY,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    dispatch_status TEXT NOT NULL DEFAULT 'PENDING',

    brain_rank INTEGER,
    brain_score NUMERIC(12,2),

    provider TEXT,
    sport_code TEXT,
    entity TEXT,

    league_id TEXT,
    season TEXT,
    run_group TEXT,

    dispatch_reason TEXT,

    dispatched_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,

    execution_result TEXT,
    execution_notes TEXT
);

CREATE INDEX IF NOT EXISTS ix_dispatch_queue_status
ON ops.dispatch_queue(dispatch_status);

CREATE INDEX IF NOT EXISTS ix_dispatch_queue_created
ON ops.dispatch_queue(created_at DESC);

CREATE INDEX IF NOT EXISTS ix_dispatch_queue_sport
ON ops.dispatch_queue(sport_code);