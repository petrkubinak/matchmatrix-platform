/*
MATCHMATRIX SQL 111_T
PLANNER REFILL FROM DISPATCH V1

CO TO JE:
- Když Dispatcher zjistí NO_PENDING_PLANNER_JOB,
  vytvoří nový pending job v ops.ingest_planner.

K ČEMU TO JE:
- Brain už ví, co chce spustit.
- Dispatcher zjistil, že planner je prázdný.
- Tento skript doplní planner queue.

BEZPEČNOST:
- Nevkládá duplicity.
- Bere pouze SKIPPED_NO_PENDING.
*/

INSERT INTO ops.ingest_planner (
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run
)
SELECT
    q.provider,
    q.sport_code,
    q.entity,
    NULLIF(q.league_id, ''),
    q.season,
    q.run_group,
    1 AS priority,
    'pending' AS status,
    0 AS attempts,
    NOW() AS next_run
FROM ops.dispatch_queue q
WHERE q.dispatch_status = 'SKIPPED_NO_PENDING'
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner p
      WHERE p.provider = q.provider
        AND p.sport_code = q.sport_code
        AND p.entity = q.entity
        AND COALESCE(p.provider_league_id, '') = COALESCE(NULLIF(q.league_id, ''), '')
        AND COALESCE(p.season, '') = COALESCE(q.season, '')
        AND COALESCE(p.run_group, '') = COALESCE(q.run_group, '')
        AND p.status = 'pending'
  );