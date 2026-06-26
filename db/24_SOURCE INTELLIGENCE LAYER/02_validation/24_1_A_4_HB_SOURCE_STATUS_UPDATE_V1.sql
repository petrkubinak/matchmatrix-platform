/*
===============================================================================
MATCHMATRIX SQL 24_1_A_4
HB SOURCE STATUS UPDATE V1
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

- První řízená aktualizace stavu HB zdrojů.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Převést obecný stav DISCOVERY na konkrétní akce.
- Připravit zdroje pro další audit.
- Připravit podklady pro SOURCE GOVERNANCE.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_intelligence_map
- SOURCE COMMAND CENTER
- OPS Panel

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Určení dalšího postupu pro každý zdroj.
- Příprava license review.
- Příprava league discovery.
- Příprava club discovery.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Aktualizuje current_status.
- Aktualizuje next_action.
- Připravuje HB Source Roadmap.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

UPDATE ops.source_intelligence_map
SET
    current_status = 'CHECK_TERMS',
    next_action = 'LICENSE_AND_ROBOTS_REVIEW',
    updated_at = now()
WHERE sport_code = 'HB'
AND source_name IN (
    'European Handball Federation',
    'International Handball Federation',
    'Wikidata',
    'Wikimedia Commons'
);

UPDATE ops.source_intelligence_map
SET
    current_status = 'DISCOVER_LEAGUES',
    next_action = 'IDENTIFY_OFFICIAL_LEAGUE_SOURCES',
    updated_at = now()
WHERE sport_code = 'HB'
AND source_name = 'Official League Websites';

UPDATE ops.source_intelligence_map
SET
    current_status = 'DISCOVER_CLUBS',
    next_action = 'IDENTIFY_OFFICIAL_CLUB_SOURCES',
    updated_at = now()
WHERE sport_code = 'HB'
AND source_name = 'Official Club Websites';

SELECT
    sport_code,
    source_name,
    source_type,
    current_status,
    next_action
FROM ops.source_intelligence_map
WHERE sport_code = 'HB'
ORDER BY priority_order;