-- 123_update_runtime_entity_audit_vb_fixtures_partial.sql

UPDATE ops.runtime_entity_audit
SET
    current_state            = 'PARTIAL',
    state_reason             = 'VB fixtures batch i unified runner probehly OK pres shared API-Sport dispatch. Pull je potvrzen logem. Run-specific RAW / parsed staging / merge delta zatim nebyly dolozeny samostatnou DB kontrolou.',
    panel_runner_exists      = TRUE,
    planner_target_exists    = TRUE,
    batch_target_exists      = TRUE,
    pull_confirmed           = TRUE,
    raw_confirmed            = FALSE,
    staging_confirmed        = FALSE,
    provider_map_confirmed   = FALSE,
    public_merge_confirmed   = FALSE,
    downstream_confirmed     = FALSE,
    last_run_group           = 'VB_CORE',
    last_run_at              = NOW(),
    last_check_at            = NOW(),
    last_log_summary         = 'run_unified_ingest_batch_v1 -> run_unified_ingest_v1 -> pull_api_sport_fixtures.ps1 | STATUS OK | shared API-Sport dispatch funguje',
    db_evidence_summary      = 'VB fixtures: log-confirmed shared pull path, ale bez dnesni DB validace RAW/staging/public delta',
    next_action              = 'Doplnit DB check pro VB fixtures: stg_api_payloads, stg_provider_fixtures a pripadny merge efekt do public.matches.',
    audit_note               = 'VB fixtures uz nejsou ve stavu skeleton dispatch problem. Orchestrace funguje, ale DB dukazni retezec jeste chybi.'
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity = 'fixtures';

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    public_merge_confirmed,
    last_run_group,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity = 'fixtures';