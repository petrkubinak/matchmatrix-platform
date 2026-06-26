/*
MATCHMATRIX SQL 111_T

PROVIDER WORKER REGISTRY V1

CO TO JE:
- Centrální registry provider/sport/entity kombinací.

K ČEMU TO JE:
- Dispatcher nebude mít natvrdo zakódované workery.
- Nové kombinace se budou přidávat datově.

KDE TO UVIDÍME:
- ops.provider_worker_registry

JAK SE TO VYUŽIJE:
Brain
 ↓
Dispatcher
 ↓
Provider Worker Registry
 ↓
Správný worker
*/

CREATE TABLE IF NOT EXISTS ops.provider_worker_registry (

    id BIGSERIAL PRIMARY KEY,

    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    entity TEXT NOT NULL,

    worker_type TEXT NOT NULL,

    worker_script TEXT,

    is_supported BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_provider_worker_registry
ON ops.provider_worker_registry (
    provider,
    sport_code,
    entity
);