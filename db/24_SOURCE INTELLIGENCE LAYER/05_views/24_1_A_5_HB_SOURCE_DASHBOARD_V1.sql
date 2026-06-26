/*
===============================================================================
MATCHMATRIX SQL 24_1_A_5
HB SOURCE DASHBOARD V1
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

- První dashboardový pohled pro HB Source Intelligence.

===============================================================================
K ČEMU TO JE:
===============================================================================

- Rychlý přehled stavu zdrojů.
- Připraveno pro OPS Panel.
- Připraveno pro budoucí SOURCE COMMAND CENTER.

===============================================================================
KDE TO UVIDÍME:
===============================================================================

- ops.v_hb_source_dashboard_v1
- SOURCE COMMAND CENTER
- OPS Panel

===============================================================================
JAK SE TO VYUŽIJE:
===============================================================================

- Monitoring zdrojů.
- Monitoring discovery procesu.
- Monitoring licence.
- Monitoring připravenosti pro harvest.

===============================================================================
CO SKRIPT DĚLÁ:
===============================================================================

- Vytváří dashboard view.
- Počítá Source Readiness.
- Třídí zdroje podle priority.

===============================================================================
AUTOR:
===============================================================================

MATCHMATRIX

===============================================================================
*/

DROP VIEW IF EXISTS ops.v_hb_source_dashboard_v1;

CREATE VIEW ops.v_hb_source_dashboard_v1 AS

SELECT
    source_map_id,
    sport_code,
    source_name,
    source_type,

    trust_score,
    automation_score,

    access_type,
    expected_depth,

    supports_players,
    supports_coaches,
    supports_photos,
    supports_profiles,
    supports_stats,
    supports_media,
    supports_historical_data,
    supports_live_data,

    current_status,
    next_action,

    CASE
        WHEN current_status = 'READY'
            THEN 'READY'

        WHEN current_status IN (
            'CHECK_TERMS',
            'DISCOVER_LEAGUES',
            'DISCOVER_CLUBS'
        )
            THEN 'IN_PROGRESS'

        WHEN current_status = 'BLOCKED'
            THEN 'BLOCKED'

        ELSE 'DISCOVERY'
    END AS dashboard_status,

    CASE
        WHEN trust_score >= 95 THEN 'A'
        WHEN trust_score >= 85 THEN 'B'
        WHEN trust_score >= 75 THEN 'C'
        ELSE 'D'
    END AS source_grade,

    created_at,
    updated_at

FROM ops.source_intelligence_map
WHERE sport_code = 'HB';

COMMENT ON VIEW ops.v_hb_source_dashboard_v1 IS
'HB Source Intelligence Dashboard V1';


SELECT
    source_name,
    source_type,
    dashboard_status,
    source_grade,
    current_status,
    next_action
FROM ops.v_hb_source_dashboard_v1
ORDER BY trust_score DESC, source_name;