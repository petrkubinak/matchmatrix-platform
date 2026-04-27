-- ============================================================
-- 202_update_runtime_entity_audit_afb_confirmed.sql
-- AFB FULL CONFIRMED podle aktuální struktury runtime_entity_audit
-- ============================================================

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    state_reason = 'AFB core pipeline potvrzena po normalizaci do stg_provider_* a real merge testu.',
    panel_runner_exists = true,
    planner_target_exists = true,
    batch_target_exists = true,
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = true,
    last_run_group = 'AFB_CORE',
    last_check_at = NOW(),
    last_log_summary = 'worker_template_multisport_v1 -> merge_runner_multisport_v1 OK; real merge idempotentni; inserted 0, skipped 0.',
    db_evidence_summary = 'AFB: stg_provider_teams=34, stg_provider_fixtures=335, public.matches=335, team_provider_map=34.',
    next_action = 'AFB core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    audit_note = 'AFB normalized from custom staging stg_api_american_football_* into generic stg_provider_*; worker + real merge hook confirmed.',
    updated_at = NOW()
WHERE provider = 'api_american_football'
  AND sport_code = 'AFB'
  AND entity IN ('teams', 'fixtures', 'leagues');

UPDATE ops.runtime_entity_audit
SET
    last_check_at = NOW(),
    last_log_summary = 'worker_template_multisport_v1 -> merge_runner_multisport_v1 OK; real merge idempotentni; inserted 0, skipped 0.',
    db_evidence_summary = CASE entity
        WHEN 'teams' THEN 'AFB normalized: stg_provider_teams=34, team_provider_map=34, real merge OK.'
        WHEN 'fixtures' THEN 'AFB normalized: stg_provider_fixtures=335, public.matches=335, real merge OK.'
        WHEN 'leagues' THEN 'AFB leagues confirmed: public.leagues ext_source=api_american_football, AFB_CORE target exists.'
        ELSE db_evidence_summary
    END,
    next_action = 'AFB core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    audit_note = 'AFB normalized from custom staging into generic stg_provider_*; worker template + real merge confirmed.',
    updated_at = NOW()
WHERE provider = 'api_american_football'
  AND sport_code = 'AFB'
  AND entity IN ('teams', 'fixtures', 'leagues')
RETURNING entity, current_state, db_evidence_summary, next_action;