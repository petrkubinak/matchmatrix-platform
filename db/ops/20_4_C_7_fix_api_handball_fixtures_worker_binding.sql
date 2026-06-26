/*
MATCHMATRIX SCRIPT

NÁZEV:
20_4_C_7_fix_api_handball_fixtures_worker_binding.sql

CO TO JE:
Oprava worker bindingu pro HB fixtures.

K ČEMU TO JE:
HB CORE padal, protože ops.ingest_entity_plan měl pro api_handball / HB / fixtures prázdný worker_script.

KDE TO UVIDÍME:
ops.ingest_entity_plan
PC2 Command Center
Operator Panel

JAK SE TO VYUŽIJE:
run_ingest_planner_jobs.py bude vědět, jaký worker/puller má pro HB fixtures spustit.
*/

BEGIN;

UPDATE ops.ingest_entity_plan
SET
    worker_script = 'ingest/API-Házená/pull_api_handball_fixtures.ps1',
    updated_at = now()
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'fixtures';

COMMIT;