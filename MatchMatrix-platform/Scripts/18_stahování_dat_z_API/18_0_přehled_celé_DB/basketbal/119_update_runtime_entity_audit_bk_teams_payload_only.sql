-- 119_update_runtime_entity_audit_bk_teams_payload_only.sql

UPDATE ops.runtime_entity_audit
SET
    current_state            = 'PARTIAL',
    state_reason             = 'BK teams reálný run proběhl OK. Dispatch do pull_api_sport_teams.ps1 potvrzen. RAW payload a stg_api_payloads potvrzeny. Parsed provider staging ve stg_provider_teams pro BK je 0, takže chain aktuálně končí na payload vrstvě.',
    pull_confirmed           = TRUE,
    raw_confirmed            = TRUE,
    staging_confirmed        = FALSE,
    provider_map_confirmed   = FALSE,
    public_merge_confirmed   = FALSE,
    downstream_confirmed     = FALSE,
    last_run_group           = 'BK_TOP',
    last_run_at              = NOW(),
    last_check_at            = NOW(),
    last_log_summary         = 'run_unified_ingest_batch_v1 -> run_unified_ingest_v1 -> pull_api_sport_teams.ps1 | RESULT OK',
    db_evidence_summary      = 'api_raw_payloads_bk_teams=58 | stg_api_payloads_bk_teams=30 | stg_provider_teams_bk=0 | team_provider_map_bk=2390',
    next_action              = 'Najít chybějící parse krok z stg_api_payloads do staging.stg_provider_teams pro BK teams.',
    audit_note               = 'BK teams mají potvrzený payload chain, ale ne parsed provider staging.'
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'teams';

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    last_run_group,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'teams';