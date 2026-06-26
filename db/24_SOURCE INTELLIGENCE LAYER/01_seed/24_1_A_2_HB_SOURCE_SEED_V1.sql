/*
===============================================================================
MATCHMATRIX SQL 24_1_A_2
HB SOURCE SEED V1
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

- První naplnění Source Intelligence Layer pro házenou.
- Evidence hlavních zdrojů hráčů, trenérů, fotografií,
  profilů, statistik, médií a historických dat.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Aby MatchMatrix věděl odkud získává informace.
- Aby bylo možné řídit kvalitu zdrojů.
- Aby bylo možné budovat People Layer.
- Aby bylo možné plánovat budoucí harvesty.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_intelligence_map
- SOURCE COMMAND CENTER
- OPS Panel
- Harvest Readiness Dashboard

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Výběr zdrojů pro harvest.
- Evidence fallback zdrojů.
- Source Governance.
- People Layer.
- Media Layer.
- Historical Layer.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Zakládá první ověřené zdroje pro HB.
- Připravuje základ HB MASTER SOURCE MAP.

===============================================================================
VSTUP:
===============================================================================

- Source Discovery Audit
- Provider Audit
- Handball Research

===============================================================================
VÝSTUP:
===============================================================================

- První registrované zdroje HB.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

INSERT INTO ops.source_intelligence_map
(
    sport_code,
    sport_name,
    entity_type,
    source_name,
    source_type,
    base_url,
    priority_order,
    trust_score,
    automation_score,
    access_type,
    supports_players,
    supports_coaches,
    supports_photos,
    supports_profiles,
    supports_stats,
    supports_media,
    supports_historical_data,
    supports_live_data,
    expected_depth,
    current_status,
    next_action,
    notes
)
VALUES

(
    'HB',
    'Handball',
    'MULTI',
    'European Handball Federation',
    'FEDERATION',
    'https://www.eurohandball.com',
    1,
    95,
    70,
    'FREE',
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    'DEEP',
    'DISCOVERY',
    'SOURCE_REVIEW',
    'Primární evropský zdroj házené.'
),

(
    'HB',
    'Handball',
    'MULTI',
    'International Handball Federation',
    'FEDERATION',
    'https://www.ihf.info',
    2,
    95,
    65,
    'FREE',
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    'DEEP',
    'DISCOVERY',
    'SOURCE_REVIEW',
    'Primární světový zdroj házené.'
),

(
    'HB',
    'Handball',
    'PLAYERS',
    'Wikidata',
    'KNOWLEDGE_BASE',
    'https://www.wikidata.org',
    10,
    80,
    95,
    'FREE',
    TRUE,
    TRUE,
    FALSE,
    TRUE,
    FALSE,
    FALSE,
    TRUE,
    FALSE,
    'MEDIUM',
    'DISCOVERY',
    'LICENSE_REVIEW',
    'Identity enrichment a propojení entit.'
),

(
    'HB',
    'Handball',
    'PHOTOS',
    'Wikimedia Commons',
    'PHOTO_ARCHIVE',
    'https://commons.wikimedia.org',
    11,
    85,
    90,
    'FREE',
    FALSE,
    FALSE,
    TRUE,
    FALSE,
    FALSE,
    FALSE,
    TRUE,
    FALSE,
    'MEDIUM',
    'DISCOVERY',
    'LICENSE_REVIEW',
    'Fotografie hráčů, trenérů a stadionů.'
),

(
    'HB',
    'Handball',
    'MULTI',
    'Official Club Websites',
    'OFFICIAL_CLUB',
    NULL,
    20,
    90,
    40,
    'REVIEW_REQUIRED',
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    'DEEP',
    'DISCOVERY',
    'DISCOVER_CLUBS',
    'Oficiální klubové profily a soupisky.'
),

(
    'HB',
    'Handball',
    'MULTI',
    'Official League Websites',
    'OFFICIAL_LEAGUE',
    NULL,
    15,
    92,
    50,
    'REVIEW_REQUIRED',
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    'DEEP',
    'DISCOVERY',
    'DISCOVER_LEAGUES',
    'Oficiální ligové zdroje.'
);

SELECT
    sport_code,
    source_name,
    source_type,
    trust_score,
    current_status
FROM ops.source_intelligence_map
WHERE sport_code = 'HB'
ORDER BY priority_order;