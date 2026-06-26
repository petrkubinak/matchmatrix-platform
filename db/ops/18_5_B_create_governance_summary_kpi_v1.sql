/*
MATCHMATRIX SQL 18_5_B
GOVERNANCE SUMMARY KPI V1

CO TO JE:
- Souhrnné KPI pro Governance Dashboard.

K ČEMU TO JE:
- Vypočítá celkové governance skóre.
- Ukáže počet potvrzených, částečných a HOLD governance oblastí.

KDE TO UVIDÍME:
- OPS Panel V18
- Governance tab
- Horní KPI blok panelu

JAK SE TO VYUŽIJE:
- Rychlé vyhodnocení, zda je databázová governance bezpečná.
- Přehled pro další rozhodnutí v OPS.
- Budoucí AI doporučení.
*/

DROP VIEW IF EXISTS ops.v_governance_summary_kpi_v1;

CREATE OR REPLACE VIEW ops.v_governance_summary_kpi_v1 AS
SELECT
    count(*) AS governance_items,
    round(avg(governance_score), 2) AS governance_score_avg,

    count(*) FILTER (WHERE current_state IN ('CONFIRMED','READY')) AS confirmed_items,
    count(*) FILTER (WHERE current_state = 'CONTROLLED_HOLD') AS controlled_hold_items,
    count(*) FILTER (WHERE current_state = 'PARTIAL') AS partial_items,
    count(*) FILTER (WHERE current_state NOT IN ('CONFIRMED','READY','CONTROLLED_HOLD','PARTIAL')) AS review_items,

    CASE
        WHEN avg(governance_score) >= 95 THEN 'READY'
        WHEN avg(governance_score) >= 85 THEN 'CONTROLLED'
        WHEN avg(governance_score) >= 60 THEN 'PARTIAL'
        ELSE 'NOT_READY'
    END AS governance_status,

    now() AS refreshed_at
FROM ops.v_governance_dashboard_v1;