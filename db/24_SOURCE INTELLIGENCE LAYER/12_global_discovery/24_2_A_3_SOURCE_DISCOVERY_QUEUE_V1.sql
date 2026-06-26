/*
===============================================================================
MATCHMATRIX SQL 24_2_A_3
SOURCE DISCOVERY QUEUE V1
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

- Fronta úkolů pro objevování nových zdrojů.
- Řídicí tabulka Source Discovery Engine.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby bylo možné systematicky rozšiřovat katalog zdrojů.
- Aby bylo možné prioritizovat audity.
- Aby bylo možné evidovat stav jednotlivých discovery úkolů.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_discovery_queue
- SOURCE COMMAND CENTER
- SOURCE INTELLIGENCE DASHBOARD
- OPS PANEL

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- AI Discovery Engine bude vytvářet nové úkoly.
- Operátor uvidí, které zdroje ještě chybí.
- Bude možné sledovat postup mapování zdrojů.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytváří discovery queue.
- Zakládá první úkoly pro všechny sporty.
- Připravuje základ pro automatizované vyhledávání zdrojů.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_discovery_queue
(
    queue_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,

    discovery_area TEXT NOT NULL,

    priority_level TEXT NOT NULL,

    queue_status TEXT DEFAULT 'OPEN',

    target_source_type TEXT,

    objective TEXT,

    next_action TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_source_discovery_queue_sport
ON ops.source_discovery_queue (sport_code);

CREATE INDEX IF NOT EXISTS ix_source_discovery_queue_status
ON ops.source_discovery_queue (queue_status);

COMMENT ON TABLE ops.source_discovery_queue IS
'Fronta úkolů pro globální Source Discovery.';


INSERT INTO ops.source_discovery_queue
(
    sport_code,
    discovery_area,
    priority_level,
    target_source_type,
    objective,
    next_action
)
VALUES

-- FOOTBALL

('FB','OFFICIAL_LEAGUES','CRITICAL','OFFICIAL_LEAGUE',
 'Identifikovat hlavní národní ligové zdroje.',
 'DISCOVER_TOP_LEAGUES'),

('FB','OFFICIAL_CLUBS','HIGH','OFFICIAL_CLUB',
 'Identifikovat hlavní klubové zdroje.',
 'DISCOVER_TOP_CLUBS'),

-- HANDBALL

('HB','OFFICIAL_LEAGUES','CRITICAL','OFFICIAL_LEAGUE',
 'Identifikovat hlavní národní ligové zdroje.',
 'DISCOVER_TOP_LEAGUES'),

('HB','OFFICIAL_CLUBS','HIGH','OFFICIAL_CLUB',
 'Identifikovat hlavní klubové zdroje.',
 'DISCOVER_TOP_CLUBS'),

-- HOCKEY

('HK','OFFICIAL_LEAGUES','CRITICAL','OFFICIAL_LEAGUE',
 'Identifikovat hlavní ligové zdroje.',
 'DISCOVER_TOP_LEAGUES'),

-- BASKETBALL

('BK','OFFICIAL_LEAGUES','CRITICAL','OFFICIAL_LEAGUE',
 'Identifikovat hlavní ligové zdroje.',
 'DISCOVER_TOP_LEAGUES'),

-- TENNIS

('TN','MEDIA_SOURCES','HIGH','MEDIA',
 'Identifikovat kvalitní media a historical zdroje.',
 'DISCOVER_MEDIA'),

-- VOLLEYBALL

('VB','OFFICIAL_LEAGUES','HIGH','OFFICIAL_LEAGUE',
 'Identifikovat hlavní ligové zdroje.',
 'DISCOVER_TOP_LEAGUES'),

-- BASEBALL

('BSB','HISTORICAL_SOURCES','HIGH','HISTORICAL',
 'Identifikovat historické baseball zdroje.',
 'DISCOVER_HISTORY'),

-- MMA

('MMA','MEDIA_SOURCES','HIGH','MEDIA',
 'Identifikovat MMA media zdroje.',
 'DISCOVER_MEDIA'),

-- AMERICAN FOOTBALL

('AFB','OFFICIAL_LEAGUES','HIGH','OFFICIAL_LEAGUE',
 'Identifikovat hlavní ligové zdroje.',
 'DISCOVER_TOP_LEAGUES'),

-- CRICKET

('CK','HISTORICAL_SOURCES','HIGH','HISTORICAL',
 'Identifikovat historické cricket zdroje.',
 'DISCOVER_HISTORY');

SELECT
    sport_code,
    discovery_area,
    priority_level,
    queue_status,
    next_action
FROM ops.source_discovery_queue
ORDER BY sport_code, priority_level DESC;