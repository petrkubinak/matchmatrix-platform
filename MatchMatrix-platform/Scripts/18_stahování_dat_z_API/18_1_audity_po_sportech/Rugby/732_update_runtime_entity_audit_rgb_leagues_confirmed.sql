-- 732_update_runtime_entity_audit_rgb_leagues_confirmed.sql

update ops.runtime_entity_audit
set
    provider = 'api_rugby',
    current_state = 'CONFIRMED',
    state_reason = 'RGB leagues end-to-end potvrzeno: pull -> raw -> staging -> public.leagues',
    panel_runner_exists = true,
    planner_target_exists = true,
    batch_target_exists = true,
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = false,
    last_run_group = 'RGB_CORE',
    last_check_at = now(),
    db_evidence_summary = 'stg_provider_leagues=142 | public.leagues=142',
    next_action = 'Navrhnout RGB teams ingest (pull -> raw -> staging -> provider_map -> public)',
    audit_note = 'RGB leagues CONFIRMED pres api_rugby.',
    updated_at = now()
where sport_code = 'RGB'
  and entity = 'leagues';