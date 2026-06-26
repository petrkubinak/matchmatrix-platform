/*
===============================================================================
MATCHMATRIX SQL 24_1_A_3
HB SOURCE VALIDATION V1
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

- První validační audit zdrojů pro házenou.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Ověřit, které zdroje jsou připravené.
- Najít zdroje bez URL.
- Najít zdroje čekající na license/robots review.
- Připravit další kroky pro discovery a harvest.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.source_intelligence_map
- budoucí SOURCE COMMAND CENTER
- OPS Panel

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Rozhodne, co doplnit ručně.
- Rozhodne, co poslat do discovery.
- Rozhodne, co čeká na kontrolu licence.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vypíše validační stav HB zdrojů.
- Spočítá readiness status.
- Ukáže next_action pro každý zdroj.

===============================================================================
VSTUP:
===============================================================================

- ops.source_intelligence_map

===============================================================================
VÝSTUP:
===============================================================================

- Přehled HB source readiness.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

SELECT
    sport_code,
    source_name,
    source_type,
    COALESCE(base_url, 'MISSING_URL') AS base_url_status,
    trust_score,
    automation_score,
    access_type,
    license_status,
    robots_status,
    expected_depth,
    current_status,
    next_action,

    CASE
        WHEN base_url IS NULL THEN 'NEEDS_SOURCE_DETAIL'
        WHEN license_status = 'NEEDS_REVIEW' THEN 'NEEDS_LICENSE_REVIEW'
        WHEN robots_status = 'NEEDS_REVIEW' THEN 'NEEDS_ROBOTS_REVIEW'
        WHEN current_status = 'DISCOVERY' THEN 'READY_FOR_DISCOVERY'
        ELSE 'CHECK_REQUIRED'
    END AS validation_status

FROM ops.source_intelligence_map
WHERE sport_code = 'HB'
ORDER BY priority_order, source_name;