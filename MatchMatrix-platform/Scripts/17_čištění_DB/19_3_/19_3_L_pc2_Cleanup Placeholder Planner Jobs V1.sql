/*
MATCHMATRIX SQL 19_3_L
PC2 Cleanup Placeholder Planner Jobs V1

CO TO JE:
- Odstraní staré PC2 placeholder joby bez provider_league_id.

K ČEMU TO JE:
- Audit nemá počítat zrušené/špatné joby jako aktivní problém.
- HB má už správné ligové joby.

KDE TO UVIDÍME:
- PC2 Execution Readiness Audit
- PC2 Command Center

JAK SE TO VYUŽIJE:
- Po cleanupu má HB přejít z LEAGUE_ID_MISSING na READY_TO_RUN.
*/

DELETE FROM ops.ingest_planner
WHERE run_group IN ('PC2_CORE_HB', 'PC2_CORE_TN')
  AND entity = 'fixtures'
  AND (provider_league_id IS NULL OR provider_league_id = '')
  AND status IN ('cancelled', 'error', 'failed');


SELECT
    execution_readiness_status,
    COUNT(*) AS command_count
FROM ops.v_pc2_execution_readiness_audit_v1
GROUP BY execution_readiness_status
ORDER BY execution_readiness_status;


SELECT
    command_id,
    sport_code,
    target_layer,
    provider,
    entity,
    planner_jobs,
    pending_jobs,
    failed_jobs,
    missing_league_jobs,
    execution_readiness_status,
    next_fix_action
FROM ops.v_pc2_execution_readiness_audit_v1
ORDER BY command_id;