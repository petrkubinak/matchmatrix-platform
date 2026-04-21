-- 735_update_runtime_entity_audit_rgb_teams_confirmed.sql

update ops.runtime_entity_audit
set
    provider = 'api_rugby',
    current_state = 'CONFIRMED',
    state_reason = 'RGB teams end-to-end potvrzeno: pull -> raw -> staging -> provider_map -> public.teams',
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
    db_evidence_summary = 'stg_provider_teams=6 | public.teams=6 | team_provider_map=6',
    next_action = 'Navrhnout RGB fixtures ingest (pull -> raw -> staging -> public.matches)',
    audit_note = 'RGB teams CONFIRMED pres api_rugby.',
    updated_at = now()
where sport_code = 'RGB'
  and entity = 'teams';