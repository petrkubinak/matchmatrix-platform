/*
MATCHMATRIX SQL 108_T
Update Unified Worker Registry Workers

CO TO JE:
- Doplnění konkrétních workerů do ops.unified_worker_registry.

K ČEMU TO JE:
- Registry už nebude ukazovat MISSING_WORKER.
- Panel bude vědět, co která entita používá.

KDE TO UVIDÍME:
- ops.unified_worker_registry
- později panel V18

JAK SE TO VYUŽIJE:
- orchestration governance
- worker audit
- panelové řízení
- scheduler intelligence
*/

UPDATE ops.unified_worker_registry
SET
    pull_worker = 'CORE_INGEST_V3',
    parse_worker = 'CORE_INGEST_V3',
    merge_worker = 'UNIFIED_MERGE_V3',
    orchestration_layer = 'CORE',
    migration_state = 'OK_UNIFIED_STAGING',
    runtime_ready = true,
    panel_ready = true,
    scheduler_ready = true,
    updated_at = NOW()
WHERE entity IN ('fixtures', 'leagues', 'teams')
  AND flow_type = 'UNIFIED_STAGING';


UPDATE ops.unified_worker_registry
SET
    pull_worker = 'PEOPLE_PIPELINE_V22',
    parse_worker = 'PEOPLE_PIPELINE_V22',
    merge_worker = 'PEOPLE_PIPELINE_V22',
    orchestration_layer = 'PEOPLE',
    migration_state = 'OK_PEOPLE_UNIFIED',
    runtime_ready = true,
    panel_ready = true,
    scheduler_ready = true,
    updated_at = NOW()
WHERE entity = 'players'
  AND provider IN (
      'api_football',
      'api_american_football',
      'api_hockey',
      'api_handball',
      'api_baseball',
      'api_rugby',
      'sportsdataio'
  );


UPDATE ops.unified_worker_registry
SET
    pull_worker = 'ODDS_PIPELINE_PLANNED',
    parse_worker = 'ODDS_PIPELINE_PLANNED',
    merge_worker = 'ODDS_MERGE_PLANNED',
    orchestration_layer = 'ODDS',
    migration_state = 'PLANNED_PRO_REQUIRED',
    runtime_ready = false,
    panel_ready = true,
    scheduler_ready = false,
    updated_at = NOW()
WHERE entity = 'odds';


UPDATE ops.unified_worker_registry
SET
    pull_worker = 'MEDIA_PIPELINE_V1',
    parse_worker = 'MEDIA_PIPELINE_V1',
    merge_worker = 'MEDIA_MERGE_V1',
    orchestration_layer = 'MEDIA',
    migration_state = 'PLANNED_OR_PARTIAL_MEDIA',
    runtime_ready = true,
    panel_ready = true,
    scheduler_ready = true,
    updated_at = NOW()
WHERE entity IN ('articles', 'highlights', 'comments');