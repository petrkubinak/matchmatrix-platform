/*
MATCHMATRIX SQL 18_5_A
GOVERNANCE DASHBOARD V1

CO TO JE:
- Hlavní Governance Dashboard View.

K ČEMU TO JE:
- Sjednotí Team, Player a League Governance.
- Poskytne jeden zdroj pro OPS Panel V18.

KDE TO UVIDÍME:
- OPS Panel V18
- Governance tab
- Projektový přehled

JAK SE TO VYUŽIJE:
- Monitoring kvality databáze
- Monitoring duplicit
- Monitoring canonical entit
- Rozhodování o dalších merge operacích
- AI doporučení
*/

DROP VIEW IF EXISTS ops.v_governance_dashboard_v1;

CREATE OR REPLACE VIEW ops.v_governance_dashboard_v1 AS

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    state_reason,
    db_evidence_summary,
    next_action,
    last_check_at,
    CASE
        WHEN current_state IN ('CONFIRMED','READY')
            THEN 100
        WHEN current_state IN ('CONTROLLED_HOLD')
            THEN 90
        WHEN current_state IN ('PARTIAL')
            THEN 60
        WHEN current_state IN ('REVIEW')
            THEN 40
        ELSE 0
    END AS governance_score
FROM ops.runtime_entity_audit

WHERE provider = 'matchmatrix_governance';