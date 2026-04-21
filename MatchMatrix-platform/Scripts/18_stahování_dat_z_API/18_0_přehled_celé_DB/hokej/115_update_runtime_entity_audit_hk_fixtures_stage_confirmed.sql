-- 115_update_runtime_entity_audit_hk_fixtures_stage_confirmed.sql

UPDATE ops.runtime_entity_audit
SET
    current_state            = 'PARTIAL',
    state_reason             = 'Reálný batch run proběhl OK. Pull fixtures potvrzen. RAW payload potvrzen. Parsed staging ve stg_provider_fixtures potvrzen. Public hockey matches v systému existují, ale dnešní run-specific merge efekt zatím není prokázán deltou.',
    pull_confirmed           = TRUE,
    raw_confirmed            = TRUE,
    staging_confirmed        = TRUE,
    provider_map_confirmed   = FALSE,
    public_merge_confirmed   = FALSE,
    downstream_confirmed     = FALSE,
    last_run_group           = 'HK_TOP',
    last_run_at              = NOW(),
    last_check_at            = NOW(),
    last_log_summary         = 'run_unified_ingest_batch_v1 -> run_unified_ingest_v1 -> pull_api_hockey_fixtures.ps1 | API call OK | results=1146 | payload ulozen do staging.stg_api_payloads | RESULT OK',
    db_evidence_summary      = 'stg_api_payloads_hk_fixtures=29 | stg_provider_fixtures_hk=2300 | public_matches_hk=1146',
    next_action              = 'Ověřit delta merge efekt HK fixtures runu do public.matches a případně match identity / canonical attach.',
    audit_note               = 'HK fixtures jsou potvrzené až do parsed provider staging vrstvy. Public hockey matches existují, ale current-run merge delta zatím nebyla izolována.'
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'fixtures';

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
    downstream_confirmed,
    last_run_group,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'fixtures';