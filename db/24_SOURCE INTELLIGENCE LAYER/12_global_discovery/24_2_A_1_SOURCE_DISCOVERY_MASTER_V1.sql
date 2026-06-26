/*
===============================================================================
MATCHMATRIX SQL 24_2_A_1
SOURCE DISCOVERY MASTER V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_2_A_GLOBAL SOURCE DISCOVERY

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Centrální katalog všech objevených zdrojů MatchMatrix.
- Master registr Source Discovery vrstvy.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Evidence federací.
- Evidence oficiálních lig.
- Evidence klubových zdrojů.
- Evidence API providerů.
- Evidence media zdrojů.
- Evidence knowledge zdrojů.
- Evidence foto zdrojů.
- Evidence historických zdrojů.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_discovery_master
- SOURCE COMMAND CENTER
- SOURCE INTELLIGENCE DASHBOARD
- OPS PANEL

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Discovery nových zdrojů.
- Audit zdrojů.
- Coverage Matrix.
- Legal Audit.
- Commercial Model.
- Quality Score.
- Activation Roadmap.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytváří hlavní registr objevených zdrojů.
- Připravuje strukturu pro všechny sporty.
- Umožní budovat globální katalog sportovních zdrojů.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_discovery_master
(
    source_discovery_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,

    source_name TEXT NOT NULL,

    source_category TEXT NOT NULL,

    source_type TEXT,

    source_url TEXT,

    discovery_status TEXT DEFAULT 'DISCOVERED',

    audit_status TEXT DEFAULT 'NOT_AUDITED',

    priority_score INTEGER DEFAULT 50,

    source_scope TEXT,

    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_source_discovery_master_sport
ON ops.source_discovery_master (sport_code);

CREATE INDEX IF NOT EXISTS ix_source_discovery_master_category
ON ops.source_discovery_master (source_category);

COMMENT ON TABLE ops.source_discovery_master IS
'Master registr všech objevených zdrojů MatchMatrix.';