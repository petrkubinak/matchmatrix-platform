-- 124_insert_runtime_entity_audit_vb_leagues.sql

INSERT INTO ops.runtime_entity_audit (
    provider,
    sport_code,
    entity,
    current_state,
    state_reason,
    panel_runner_exists,
    planner_target_exists,
    batch_target_exists,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    last_run_group,
    last_run_at,
    last_check_at,
    last_log_summary,
    db_evidence_summary,
    next_action,
    audit_note,
    created_at,
    updated_at
)
VALUES (
    'api_volleyball',
    'VB',
    'leagues',
    'PARTIAL',
    'VB leagues batch i unified runner probehly OK pres shared API-Sport dispatch. Pull je potvrzen logem. Dnes ale nebyla provedena samostatna DB validace RAW/staging/public vrstvy.',
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    FALSE,
    FALSE,
    FALSE,
    FALSE,
    FALSE,
    'VB_CORE',
    NOW(),
    NOW(),
    'run_unified_ingest_batch_v1 -> run_unified_ingest_v1 -> pull_api_sport_leagues.ps1 | STATUS OK | shared API-Sport dispatch funguje',
    'VB leagues: log-confirmed shared pull path, ale bez dnesni DB validace stg_provider_leagues / public.leagues delta',
    'Doplnit DB check pro VB leagues: stg_api_payloads, stg_provider_leagues a pripadne canonical/public dopady.',
    'VB leagues orchestrace funguje. Audit je zatim potvrzen logem, ne plnym DB dukaznim retezcem.',
    NOW(),
    NOW()
);

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