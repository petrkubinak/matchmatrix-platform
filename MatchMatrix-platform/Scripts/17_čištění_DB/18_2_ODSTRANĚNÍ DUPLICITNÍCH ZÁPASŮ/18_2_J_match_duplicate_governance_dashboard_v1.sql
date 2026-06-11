/*
MATCHMATRIX SQL 18_2_J Match Duplicate Governance Dashboard V1

CO TO JE:
- Souhrnný dashboard pro Match Duplicate Governance.

K ČEMU TO JE:
- Ukáže aktuální stav duplicit zápasů po safe delete provider duplicit.

KDE TO UVIDÍME:
- OPS panel / Governance Dashboard.

JAK SE TO VYUŽIJE:
- Pro kontrolu remaining problémů:
  LEAGUE_MAPPING_ERROR
  REVIEW_REQUIRED
  SCORE_CONFLICT_REVIEW
*/

CREATE OR REPLACE VIEW ops.v_match_duplicate_governance_dashboard_v1 AS

SELECT
    governance_status,
    COUNT(*) AS affected_rows,
    COUNT(DISTINCT sport_id || '|' || match_date || '|' || team_low || '|' || team_high) AS affected_groups,
    MIN(match_date) AS oldest_match_date,
    MAX(match_date) AS newest_match_date
FROM ops.v_match_duplicate_governance_audit_v1
GROUP BY governance_status

UNION ALL

SELECT
    'SAFE_PROVIDER_DUPLICATES_DELETED' AS governance_status,
    COUNT(*) AS affected_rows,
    COUNT(DISTINCT master_match_id) AS affected_groups,
    MIN(kickoff::date) AS oldest_match_date,
    MAX(kickoff::date) AS newest_match_date
FROM ops.match_safe_delete_run_log
WHERE run_note = '18_2_H_SAFE_DELETE_PROVIDER_DUPLICATES';