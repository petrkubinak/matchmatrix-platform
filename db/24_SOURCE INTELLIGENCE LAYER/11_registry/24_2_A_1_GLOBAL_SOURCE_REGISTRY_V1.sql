/*
===============================================================================
MATCHMATRIX SQL 24_2_A_1
GLOBAL SOURCE REGISTRY V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_2_GLOBAL_SOURCE_REGISTRY

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Centrální registr všech sportovních zdrojů MatchMatrix.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Evidence federací.
- Evidence lig.
- Evidence klubových zdrojů.
- Evidence API providerů.
- Evidence media zdrojů.
- Evidence knowledge zdrojů.
- Evidence foto zdrojů.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.global_source_registry
- SOURCE COMMAND CENTER
- SOURCE INTELLIGENCE DASHBOARD
- OPS PANEL

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Discovery nových zdrojů.
- Hodnocení zdrojů.
- Source governance.
- Business intelligence.
- Harvest readiness.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX
===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.global_source_registry
(
    source_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,

    source_name TEXT NOT NULL,

    source_type TEXT NOT NULL,

    source_level TEXT,

    source_url TEXT,

    source_status TEXT DEFAULT 'DISCOVERED',

    discovery_status TEXT DEFAULT 'OPEN',

    verification_status TEXT DEFAULT 'NOT_VERIFIED',

    commercial_status TEXT DEFAULT 'UNKNOWN',

    people_supported BOOLEAN DEFAULT FALSE,
    coaches_supported BOOLEAN DEFAULT FALSE,
    photos_supported BOOLEAN DEFAULT FALSE,
    statistics_supported BOOLEAN DEFAULT FALSE,
    history_supported BOOLEAN DEFAULT FALSE,
    media_supported BOOLEAN DEFAULT FALSE,

    priority_score INTEGER DEFAULT 50,

    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_global_source_registry_sport
ON ops.global_source_registry (sport_code);

CREATE INDEX IF NOT EXISTS ix_global_source_registry_type
ON ops.global_source_registry (source_type);

COMMENT ON TABLE ops.global_source_registry IS
'Master registr všech sportovních zdrojů MatchMatrix.';