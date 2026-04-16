-- 124_update_runtime_entity_audit_vb_leagues_partial.sql

UPDATE ops.runtime_entity_audit
SET
    current_state            = 'PARTIAL',
    state_reason             = 'VB leagues batch i unified runner probehly OK pres shared API-Sport dispatch. Pull je potvrzen logem. Dnes ale nebyla provedena samostatna DB validace RAW/staging/public vrstvy.',
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
    last_log_summary         = 'run_unified_ingest_batch_v1 -> run_unified_ingest_v1 -> pull_api_sport_leagues.ps1 | STATUS OK | shared API-Sport dispatch funguje',
    db_evidence_summary      = 'VB leagues: log-confirmed shared pull path, ale bez dnesni DB validace stg_provider_leagues / public.leagues delta',
    next_action              = 'Doplnit DB check pro VB leagues: stg_api_payloads, stg_provider_leagues a pripadne canonical/public dopady.',
    audit_note               = 'VB leagues orchestrace funguje. Audit je zatim potvrzen logem, ne plnym DB dukaznim retezcem.'
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity = 'leagues';

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
  AND entity = 'leagues';