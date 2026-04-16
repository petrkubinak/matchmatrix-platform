-- 704_update_runtime_entity_audit_afb_teams.sql
-- AFB teams - potvrzeni runtime_entity_audit
-- Spoustet v DBeaveru

update ops.runtime_entity_audit
set
    current_state = 'CONFIRMED',
    state_reason = 'AFB teams end-to-end potvrzeno: pull -> raw -> staging -> provider_map -> public teams',
    panel_runner_exists = true,
    planner_target_exists = true,
    batch_target_exists = true,
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = false,
    last_run_group = 'AFB_CORE',
    last_run_at = now(),
    last_check_at = now(),
    last_log_summary = 'AFB teams pull OK | RAW saved | parser OK | merge to public.teams OK',
    db_evidence_summary = 'stg_api_american_football_teams=34 | public.teams ext_source=api_american_football=34 | team_provider_map api_american_football=34',
    next_action = 'Pripravit AFB fixtures pipeline stejnym patternem.',
    audit_note = 'AFB teams jsou potvrzene v canonical public vrstve. Pozdeji zvazit filtraci konferencnich entit AFC/NFC.',
    updated_at = now()
where provider = 'api_american_football'
  and sport_code = 'AFB'
  and entity = 'teams';

select
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
    db_evidence_summary
from ops.runtime_entity_audit
where provider = 'api_american_football'
  and sport_code = 'AFB'
  and entity = 'teams';