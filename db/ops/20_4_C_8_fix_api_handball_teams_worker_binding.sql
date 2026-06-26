/*
MATCHMATRIX SCRIPT

NÁZEV:
20_4_C_8_fix_api_handball_teams_worker_binding.sql

CO TO JE:
Oprava worker bindingu pro HB Teams.

K ČEMU TO JE:
HB Teams planner má 633 pending jobů, ale ops.ingest_entity_plan má worker_script = NULL.
Planner tedy neví, jaký puller má pro api_handball / HB / teams spustit.

KDE TO UVIDÍME:
ops.ingest_entity_plan
ops.ingest_planner
staging.stg_provider_teams

JAK SE TO VYUŽIJE:
Umožní spustit HB Teams Completion a doplnit chybějící týmy pro odblokování HB fixtures merge.
*/

BEGIN;

UPDATE ops.ingest_entity_plan
SET
    worker_script = 'ingest/API-Házená/pull_api_handball_teams.ps1',
    updated_at = now()
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'teams';

COMMIT;