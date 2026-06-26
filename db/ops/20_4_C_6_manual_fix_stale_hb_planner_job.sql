/*
MATCHMATRIX
20_4_C_6_manual_fix_stale_hb_planner_job.sql

CO TO JE:
Bezpečné vrácení zaseknutého HB planner jobu do pending.

K ČEMU TO JE:
Job zůstal ve stavu running po starém neúspěšném běhu.
Vrátíme ho do pending, aby ho PC2 mohl znovu zpracovat.

KDE TO UVIDÍME:
ops.ingest_planner
OPS Panel / PC2 Command Center

JAK SE TO VYUŽIJE:
Příprava HB CORE pro opětovné spuštění.
*/

BEGIN;

UPDATE ops.ingest_planner
SET
    status = 'pending',
    updated_at = now(),
    next_run = now()
WHERE id = 8874
  AND status = 'running'
  AND updated_at < now() - interval '2 hours';

COMMIT;