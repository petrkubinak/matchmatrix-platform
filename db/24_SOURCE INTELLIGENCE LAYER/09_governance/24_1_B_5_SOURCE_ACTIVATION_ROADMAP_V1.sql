/*
===============================================================================
MATCHMATRIX SQL 24_1_B_5
SOURCE ACTIVATION ROADMAP V1
===============================================================================

VRSTVA:
24_SOURCE INTELLIGENCE LAYER

OBLAST:
24_1_B_SOURCE GOVERNANCE LAYER

VERZE:
V1

===============================================================================
CO TO JE:
===============================================================================

- Centrální roadmapa aktivace datových zdrojů MatchMatrix.
- Definuje kdy a za jakých podmínek má být zdroj použit.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby MatchMatrix věděl které zdroje používat okamžitě.
- Aby bylo možné plánovat aktivaci placených providerů.
- Aby AI Orchestrator znal doporučený postup použití zdrojů.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_activation_roadmap
- SOURCE INTELLIGENCE DASHBOARD
- SOURCE COMMAND CENTER
- OPS PANEL
- AI ORCHESTRATOR

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Výběr zdrojů pro harvest.
- Výběr zdrojů pro People Layer.
- Výběr zdrojů pro Media Layer.
- Výběr zdrojů pro History Layer.
- Rozhodování o nákupu placených providerů.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytváří roadmapu aktivace zdrojů.
- Zakládá první záznamy pro HB.
- Připravuje framework pro všechny sporty.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

CREATE TABLE IF NOT EXISTS ops.source_activation_roadmap
(
    activation_id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    source_name TEXT NOT NULL,

    source_tier TEXT,

    activation_status TEXT NOT NULL,

    activation_priority INTEGER,

    activation_reason TEXT,

    activation_trigger TEXT,

    legal_ready BOOLEAN DEFAULT FALSE,
    commercial_ready BOOLEAN DEFAULT FALSE,
    technical_ready BOOLEAN DEFAULT FALSE,

    target_layer TEXT,

    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_source_activation_roadmap_sport
ON ops.source_activation_roadmap (sport_code);

CREATE INDEX IF NOT EXISTS ix_source_activation_roadmap_status
ON ops.source_activation_roadmap (activation_status);

COMMENT ON TABLE ops.source_activation_roadmap IS
'Roadmap aktivace zdrojů MatchMatrix.';


INSERT INTO ops.source_activation_roadmap
(
    sport_code,
    source_name,
    source_tier,

    activation_status,
    activation_priority,

    activation_reason,
    activation_trigger,

    legal_ready,
    commercial_ready,
    technical_ready,

    target_layer,

    notes
)
VALUES
(
    'HB',
    'European Handball Federation',
    'TIER_1',

    'USE_NOW_AFTER_LEGAL_REVIEW',
    100,

    'Tier 1 zdroj pro evropskou házenou.',
    'TERMS_AND_PHOTO_LICENSE_REVIEW_COMPLETE',

    FALSE,
    TRUE,
    TRUE,

    'PEOPLE,HISTORY,SPORT_CORE',

    'Ověřeni hráči, trenéři, staff, fotky, historie a evropské soutěže. Čeká na dokončení Terms & Photo License review.'
),

(
    'HB',
    'International Handball Federation',
    'UNKNOWN',

    'RESEARCH_REQUIRED',
    95,

    'Globální federace házené.',
    'SOURCE_AUDIT_COMPLETE',

    FALSE,
    TRUE,
    FALSE,

    'PEOPLE,HISTORY,WORLD_COMPETITIONS',

    'Další prioritní audit po EHF.'
),

(
    'HB',
    'Wikidata',
    'SUPPORTING_SOURCE',

    'USE_NOW',
    70,

    'Knowledge graph a doplnění identit.',
    'NONE',

    TRUE,
    TRUE,
    TRUE,

    'PEOPLE,KNOWLEDGE',

    'Doplňkový zdroj identit a vztahů.'
),

(
    'HB',
    'Wikimedia Commons',
    'SUPPORTING_SOURCE',

    'USE_AFTER_LICENSE_REVIEW',
    60,

    'Zdroj fotografií.',
    'PHOTO_LICENSE_REVIEW_COMPLETE',

    FALSE,
    TRUE,
    TRUE,

    'PHOTOS',

    'Nutná kontrola licence jednotlivých souborů.'
);

SELECT
    sport_code,
    source_name,
    source_tier,
    activation_status,
    activation_priority,
    target_layer
FROM ops.source_activation_roadmap
ORDER BY activation_priority DESC;