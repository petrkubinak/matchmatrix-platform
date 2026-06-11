/*
MATCHMATRIX SQL 23_3_P

PC2 GO LIVE SUMMARY V1

CO TO JE:
- Finální souhrn připravenosti PC2.

K ČEMU TO JE:
- Jediný KPI pohled pro OPS Panel.
- Ukazuje skutečnou připravenost spuštění PC2.

KDE TO UVIDÍME:
- OPS Panel
- PC2 Dashboard
- Harvest Readiness

JAK SE TO VYUŽIJE:
- Rozhodnutí kdy zapnout PC2.
- Přehled zbývajících blokací.
- Vstup pro AI doporučení.

NAVAZUJE NA:
- 23_3_O_create_pc2_go_live_checklist_v1.sql

DALŠÍ KROK:
- Napojení do OPS Panel V18/V19
*/

DROP VIEW IF EXISTS ops.v_pc2_go_live_summary_v1;

CREATE OR REPLACE VIEW ops.v_pc2_go_live_summary_v1 AS

WITH s AS (

    SELECT

        COUNT(*) AS total_checks,

        COUNT(*) FILTER (
            WHERE check_status = 'DONE'
        ) AS done_checks,

        COUNT(*) FILTER (
            WHERE check_status <> 'DONE'
        ) AS pending_checks

    FROM ops.v_pc2_go_live_checklist_v1

),

top_blockers AS (

    SELECT
        string_agg(
            checklist_area || ': ' || checklist_item,
            ' | '
            ORDER BY checklist_order
        ) AS blocker_list

    FROM (
        SELECT *
        FROM ops.v_pc2_go_live_checklist_v1
        WHERE check_status <> 'DONE'
        ORDER BY checklist_order
        LIMIT 5
    ) x

)

SELECT

    total_checks,

    done_checks,

    pending_checks,

    ROUND(
        100.0 * done_checks / NULLIF(total_checks,0),
        2
    ) AS readiness_pct,

    CASE

        WHEN ROUND(
            100.0 * done_checks / NULLIF(total_checks,0),
            2
        ) >= 90
        THEN 'READY_FOR_GO_LIVE'

        WHEN ROUND(
            100.0 * done_checks / NULLIF(total_checks,0),
            2
        ) >= 70
        THEN 'NEAR_READY'

        WHEN ROUND(
            100.0 * done_checks / NULLIF(total_checks,0),
            2
        ) >= 50
        THEN 'IN_PROGRESS'

        ELSE 'NOT_READY'

    END AS readiness_status,

    blocker_list,

    CASE

        WHEN pending_checks = 0
            THEN 'PC2 lze aktivovat.'

        ELSE
            'Dokončit pending checklist položky.'

    END AS recommended_next_action,

    now() AS refreshed_at

FROM s
CROSS JOIN top_blockers;