-- 121_update_runtime_entity_audit_bk_fixtures_stage_confirmed.sql

UPDATE ops.runtime_entity_audit
SET
    current_state            = 'PARTIAL',
    state_reason             = 'BK fixtures reálný run proběhl OK. Pull potvrzen. RAW payload potvrzen. Parsed staging ve stg_provider_fixtures potvrzen. Public basketbal matches v systému existují, ale dnešní run-specific merge delta zatím není prokázána.',
    pull_confirmed           = TRUE,
    raw_confirmed            = TRUE,
    staging_confirmed        = TRUE,
    provider_map_confirmed   = FALSE,
    public_merge_confirmed   = FALSE,
    downstream_confirmed     = FALSE,
    last_run_group           = 'BK_TOP',
    last_run_at              = NOW(),
    last_check_at            = NOW(),
    last_log_summary         = 'run_unified_ingest_batch_v1 -> run_unified_ingest_v1 -> pull_api_sport_fixtures.ps1 | RESULT OK',
    db_evidence_summary      = 'api_raw_payloads_bk_fixtures=14 | stg_api_payloads_bk_fixtures=57 | stg_provider_fixtures_bk=326 | public_matches_bk=1217',
    next_action              = 'Ověřit run-specific merge delta do public.matches a pak řešit BK teams parse gap.',
    audit_note               = 'BK fixtures jsou potvrzené až do parsed provider staging vrstvy. Public basketbal matches v systému existují.'
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
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