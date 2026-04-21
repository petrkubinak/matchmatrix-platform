-- 126_update_runtime_entity_audit_vb_teams_partial.sql

UPDATE ops.runtime_entity_audit
SET
    current_state            = 'PARTIAL',
    state_reason             = 'VB teams batch i unified runner probehly OK pres shared API-Sport dispatch. Pull je potvrzen logem. Dnes ale nebyla provedena samostatna DB validace RAW/staging/public vrstvy.',
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
    last_log_summary         = 'run_unified_ingest_batch_v1 -> run_unified_ingest_v1 -> pull_api_sport_teams.ps1 | STATUS OK | shared API-Sport dispatch funguje',
    db_evidence_summary      = 'VB teams: log-confirmed shared pull path, ale bez dnesni DB validace stg_api_payloads / stg_provider_teams / public teams delta',
    next_action              = 'Doplnit DB check pro VB teams: stg_api_payloads, stg_provider_teams a pripadne provider_map/public teams dopady.',
    audit_note               = 'VB teams uz nejsou jen planned seed. Orchestrace funguje, ale DB dukazni retezec jeste chybi.',
    updated_at               = NOW()
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity = 'teams';

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
  AND entity = 'teams';