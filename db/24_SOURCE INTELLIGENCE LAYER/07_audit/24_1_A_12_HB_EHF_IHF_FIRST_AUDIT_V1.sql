/*
===============================================================================
MATCHMATRIX SQL 24_1_A_12
HB EHF IHF FIRST AUDIT V1
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

- První skutečný audit EHF a IHF.
- Připraveno pro ukládání reálných výsledků ověření.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Přechod od návrhu k reálnému ověřování.
- Uložení skutečných zjištění.
- Založení historie auditů.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_verification_log
- ops.source_review_results
- SOURCE COMMAND CENTER
- SOURCE GOVERNANCE

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Evidence ověřených zdrojů.
- Evidence licence.
- Evidence robots.
- Budoucí monitoring změn.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

/*
=========================================================================
KROK 1
Přehled auditních položek čekajících na ověření
=========================================================================
*/

SELECT
    source_name,
    review_area,
    review_item,
    current_status,
    next_action
FROM ops.source_discovery_review_plan
WHERE sport_code = 'HB'
AND source_name IN
(
    'European Handball Federation',
    'International Handball Federation'
)
ORDER BY source_name, priority_score DESC;


/*
=========================================================================
KROK 2
Přehled dosavadních auditních výsledků
=========================================================================
*/

SELECT
    source_name,
    review_area,
    review_item,
    review_result,
    review_date,
    next_action
FROM ops.source_review_results
WHERE sport_code = 'HB'
ORDER BY source_name, review_area, review_item;


/*
=========================================================================
KROK 3
Přehled verification logu
=========================================================================
*/

SELECT
    source_name,
    verification_area,
    verification_item,
    verification_result,
    verification_date,
    next_action
FROM ops.source_verification_log
WHERE sport_code = 'HB'
ORDER BY source_name, verification_area, verification_item;