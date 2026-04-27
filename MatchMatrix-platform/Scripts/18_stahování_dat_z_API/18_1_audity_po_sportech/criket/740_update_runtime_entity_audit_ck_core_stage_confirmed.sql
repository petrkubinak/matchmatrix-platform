-- 740_update_runtime_entity_audit_ck_core_stage_confirmed.sql

UPDATE ops.runtime_entity_audit
SET
    current_state = 'PARTIAL',
    state_reason = 'CK core raw + staging potvrzeny v novem modelu',
    panel_runner_exists = false,
    planner_target_exists = false,
    batch_target_exists = false,
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = false,
    public_merge_confirmed = false,
    downstream_confirmed = false,
    last_run_group = 'CK_CORE',
    last_check_at = now(),
    last_log_summary = 'CK fixtures/leagues/teams raw+staging confirmed | stg_api_payloads parsed: fixtures=2, leagues=1, teams=1 | stg_provider_fixtures=44 | stg_provider_leagues=32 | stg_provider_teams=37',
    db_evidence_summary = 'api_cricket CK core staging potvrzen: fixtures 44, leagues 32, teams 37',
    next_action = 'Navrhnout a otestovat CK public merge pro leagues, teams a fixtures',
    audit_note = 'CK jede pres novy genericky staging model stg_api_payloads + stg_provider_*',
    updated_at = now()
WHERE provider = 'api_cricket'
  AND sport_code = 'CK'
  AND entity IN ('fixtures', 'leagues', 'teams');