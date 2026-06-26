/*
===============================================================================
MATCHMATRIX SQL 24_1_A_7
HB SOURCE QUEUE DASHBOARD V1
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

- Dashboard nad HB discovery frontou.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Přehled otevřených úkolů.
- Prioritizace discovery práce.
- Budoucí Source Command Center.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.v_hb_source_queue_dashboard_v1
- OPS Panel
- SOURCE COMMAND CENTER

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Řízení discovery procesu.
- Sledování postupu validace zdrojů.
- Monitoring otevřených úkolů.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

DROP VIEW IF EXISTS ops.v_hb_source_queue_dashboard_v1;

CREATE VIEW ops.v_hb_source_queue_dashboard_v1 AS

SELECT
    discovery_id,
    sport_code,
    source_name,
    discovery_type,
    priority_score,
    current_status,
    next_action,

    CASE
        WHEN priority_score >= 95 THEN 'CRITICAL'
        WHEN priority_score >= 80 THEN 'HIGH'
        WHEN priority_score >= 60 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS priority_band,

    created_at,
    updated_at

FROM ops.source_discovery_queue
WHERE sport_code = 'HB';

COMMENT ON VIEW ops.v_hb_source_queue_dashboard_v1 IS
'HB Source Discovery Queue Dashboard V1';

SELECT
    source_name,
    discovery_type,
    priority_band,
    current_status,
    next_action
FROM ops.v_hb_source_queue_dashboard_v1
ORDER BY priority_score DESC;