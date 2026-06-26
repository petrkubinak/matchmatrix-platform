/*
MATCHMATRIX SQL 18_2_G Match Safe Delete Execution Plan V1

CO TO JE:
- Finální plán bezpečného odstranění duplicitních zápasů.

K ČEMU TO JE:
- Připraví přesný seznam duplicate_match_id, které lze odstranit.

KDE TO UVIDÍME:
- OPS Governance.

JAK SE TO VYUŽIJE:
- Další krok 18_2_H provede DELETE pouze nad těmito SAFE řádky.
*/

CREATE OR REPLACE VIEW ops.v_match_safe_delete_execution_plan_v1 AS

SELECT
    duplicate_match_id,
    master_match_id,
    duplicate_ext_source,
    duplicate_ext_match_id,
    kickoff,
    home_team,
    away_team,
    'SAFE_DELETE' AS execution_action
FROM ops.v_match_safe_delete_candidate_audit_v1
WHERE safe_delete_status = 'SAFE_DELETE_READY';