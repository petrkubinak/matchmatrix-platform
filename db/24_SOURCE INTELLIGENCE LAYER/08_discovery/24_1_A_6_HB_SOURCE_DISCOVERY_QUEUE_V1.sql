/*
===============================================================================
MATCHMATRIX SQL 24_1_A_6
HB SOURCE DISCOVERY QUEUE V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_1_MASTER_SOURCE_MAP

SPORT:
HB - HANDBALL

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Discovery fronta pro ověřování a rozšiřování zdrojů házené.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby bylo možné systematicky objevovat nové zdroje.
- Aby bylo možné evidovat rozpracované úkoly.
- Aby bylo možné řídit Source Intelligence Layer.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_discovery_queue
- SOURCE COMMAND CENTER
- OPS Panel
- Source Governance Dashboard

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Evidence úkolů pro discovery.
- Evidence stavu ověřování.
- Budoucí automatické discovery workery.
- Prioritizace nových zdrojů.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytváří discovery queue.
- Zakládá první HB discovery úkoly.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_discovery_queue
(
    discovery_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    source_name TEXT NOT NULL,

    discovery_type TEXT NOT NULL,

    priority_score INTEGER DEFAULT 50,

    current_status TEXT DEFAULT 'PENDING',

    assigned_worker TEXT,

    next_action TEXT,

    discovery_notes TEXT,

    discovered_url TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS ix_source_discovery_queue_sport
ON ops.source_discovery_queue (sport_code);

CREATE INDEX IF NOT EXISTS ix_source_discovery_queue_status
ON ops.source_discovery_queue (current_status);

INSERT INTO ops.source_discovery_queue
(
    sport_code,
    source_name,
    discovery_type,
    priority_score,
    current_status,
    next_action,
    discovery_notes
)
VALUES

(
    'HB',
    'European Handball Federation',
    'LICENSE_REVIEW',
    100,
    'OPEN',
    'CHECK_TERMS_AND_ROBOTS',
    'Prověřit licence, robots.txt a možnosti automatizace.'
),

(
    'HB',
    'International Handball Federation',
    'LICENSE_REVIEW',
    100,
    'OPEN',
    'CHECK_TERMS_AND_ROBOTS',
    'Prověřit licence, robots.txt a možnosti automatizace.'
),

(
    'HB',
    'Official League Websites',
    'LEAGUE_DISCOVERY',
    95,
    'OPEN',
    'IDENTIFY_TOP_HB_LEAGUES',
    'Najít oficiální weby hlavních házenkářských soutěží.'
),

(
    'HB',
    'Official Club Websites',
    'CLUB_DISCOVERY',
    90,
    'OPEN',
    'IDENTIFY_TOP_HB_CLUBS',
    'Najít oficiální weby hlavních házenkářských klubů.'
),

(
    'HB',
    'Wikimedia Commons',
    'PHOTO_REVIEW',
    80,
    'OPEN',
    'VERIFY_LICENSE_MODEL',
    'Ověřit vhodnost pro foto enrichment.'
),

(
    'HB',
    'Wikidata',
    'ENTITY_ENRICHMENT',
    70,
    'OPEN',
    'VERIFY_ENTITY_MAPPING',
    'Ověřit využití pro identity a knowledge graph.'
);

SELECT
    discovery_id,
    sport_code,
    source_name,
    discovery_type,
    priority_score,
    current_status,
    next_action
FROM ops.source_discovery_queue
WHERE sport_code = 'HB'
ORDER BY priority_score DESC;