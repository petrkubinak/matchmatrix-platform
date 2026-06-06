/*
MATCHMATRIX SQL 111_G Coverage Priority Dashboard V1

CO TO JE:
- Prioritizační dashboard.

K ČEMU TO JE:
- Ukáže co má největší hodnotu dokončit.
- Pomůže plánovat další vývoj.
- AI OPS bude vědět co řešit jako první.

KDE TO UVIDÍME:
- Panel V18+
- Coverage Dashboard
- AI OPS

JAK SE TO VYUŽIJE:
- Co chybí
- Jak je to důležité
- Jaká je priorita dokončení
*/


CREATE OR REPLACE VIEW ops.v_coverage_priority_dashboard_v1 AS
SELECT

    sport_code,
    entity,

    COUNT(*) FILTER (
        WHERE gap_status_code='READY'
    ) AS ready_count,

    COUNT(*) FILTER (
        WHERE gap_status_code='NOT_IMPLEMENTED_YET'
    ) AS missing_count,

    COUNT(*) FILTER (
        WHERE gap_status_code='WAIT_FOR_PAID_PLAN'
    ) AS paid_count,

    CASE

        /* FB */

        WHEN sport_code='FB'
         AND entity IN
         (
            'players',
            'player_stats',
            'player_season_stats',
            'odds'
         )
        THEN 100

        /* BK */

        WHEN sport_code='BK'
         AND entity IN
         (
            'players',
            'odds'
         )
        THEN 90

        /* HK */

        WHEN sport_code='HK'
         AND entity IN
         (
            'players',
            'odds'
         )
        THEN 85

        /* HB */

        WHEN sport_code='HB'
         AND entity IN
         (
            'players',
            'odds'
         )
        THEN 80

        /* VB */

        WHEN sport_code='VB'
         AND entity IN
         (
            'players',
            'odds'
         )
        THEN 75

        ELSE 50

    END AS business_priority

FROM ops.v_data_gap_engine_v2
GROUP BY
    sport_code,
    entity;



CREATE OR REPLACE VIEW ops.v_coverage_priority_panel_v1 AS
SELECT

    sport_code           AS "Sport",
    entity               AS "Entita",

    ready_count          AS "READY",
    missing_count        AS "CHYBÍ",
    paid_count           AS "ČEKÁ NA PRO",

    business_priority    AS "Priorita"

FROM ops.v_coverage_priority_dashboard_v1
ORDER BY

    business_priority DESC,
    missing_count DESC,
    sport_code,
    entity;