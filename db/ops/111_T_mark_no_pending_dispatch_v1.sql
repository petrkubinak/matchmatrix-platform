/*
MATCHMATRIX SQL 111_T
MARK NO PENDING DISPATCH V1

CO TO JE:
- Označí dispatch položky bez pending planner jobu jako SKIPPED_NO_PENDING.

K ČEMU TO JE:
- Dispatcher nebude držet SELECTED/PENDING akce, které nelze spustit.
*/

UPDATE ops.dispatch_queue q
SET
    dispatch_status = 'SKIPPED_NO_PENDING',
    completed_at = NOW(),
    execution_result = 'NO_PENDING_PLANNER_JOB',
    execution_notes = 'Dispatcher kontrola: pro run_group neexistuje žádný pending planner job.'
FROM ops.v_dispatch_readiness_v1 r
WHERE r.dispatch_id = q.id
  AND r.readiness_status = 'NO_PENDING_PLANNER_JOB'
  AND q.dispatch_status IN ('PENDING', 'SELECTED')
RETURNING
    q.id,
    q.sport_code,
    q.entity,
    q.run_group,
    q.dispatch_status,
    q.execution_result;