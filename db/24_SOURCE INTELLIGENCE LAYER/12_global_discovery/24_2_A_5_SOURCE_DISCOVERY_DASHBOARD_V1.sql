/*
===============================================================================
MATCHMATRIX SQL 24_2_A_5
SOURCE DISCOVERY DASHBOARD V1
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

- Dashboard pohled nad Source Discovery.
- Souhrn auditů všech zdrojů.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Rychlý přehled stavu Source Intelligence.
- Identifikace prioritních auditů.
- Přehled dokončených auditů.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.v_source_discovery_dashboard_v1
- SOURCE COMMAND CENTER
- OPS PANEL

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Denní řízení auditů zdrojů.
- Prioritizace práce.
- Budoucí AI Discovery Monitoring.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytváří dashboard view.
- Počítá OPEN / DONE / PARTIAL.
- Zobrazuje další akci.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_source_discovery_status_dashboard_v1
AS
SELECT
    sport_code,

    COUNT(*) AS total_sources,

    COUNT(*) FILTER
    (
        WHERE audit_status = 'OPEN'
    ) AS open_sources,

    COUNT(*) FILTER
    (
        WHERE audit_status = 'DONE'
    ) AS done_sources,

    COUNT(*) FILTER
    (
        WHERE legal_audit_status = 'PARTIAL'
    ) AS partial_legal_sources,

    MAX(priority_score) AS highest_priority

FROM ops.source_discovery_audit_tracker
GROUP BY sport_code;

COMMENT ON VIEW ops.v_source_discovery_status_dashboard_v1 IS
'Source Discovery Status Dashboard V1 - souhrn auditních stavů zdrojů.';