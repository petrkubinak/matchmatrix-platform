-- 707_upsert_runtime_entity_audit_afb_fixtures.sql
-- AFB fixtures - insert/update do ops.runtime_entity_audit
-- Spoustet v DBeaveru

update ops.runtime_entity_audit
set
    current_state = 'CONFIRMED',
    state_reason = 'AFB fixtures end-to-end potvrzeno: pull -> raw -> staging -> public.matches',
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
    last_log_summary = 'AFB fixtures pull OK | RAW saved | parser OK | merge to public.matches OK',
    db_evidence_summary = 'stg_api_american_football_fixtures=335 | public.matches ext_source=api_american_football=335 | FINISHED=318 | SCHEDULED=17',
    next_action = 'Zafixovat AFB leagues audit a potom finalni sport completion audit.',
    audit_note = 'AFB fixtures jsou potvrzene v canonical public.matches vrstve pres team_provider_map.',
    updated_at = now()
where provider = 'api_american_football'
  and sport_code = 'AFB'
  and entity = 'fixtures';

insert into ops.runtime_entity_audit (
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
select
    'api_american_football',
    'AFB',
    'fixtures',
    'CONFIRMED',
    'AFB fixtures end-to-end potvrzeno: pull -> raw -> staging -> public.matches',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    'AFB_CORE',
    now(),
    now(),
    'AFB fixtures pull OK | RAW saved | parser OK | merge to public.matches OK',
    'stg_api_american_football_fixtures=335 | public.matches ext_source=api_american_football=335 | FINISHED=318 | SCHEDULED=17',
    'Zafixovat AFB leagues audit a potom finalni sport completion audit.',
    'AFB fixtures jsou potvrzene v canonical public.matches vrstve pres team_provider_map.',
    now(),
    now()
where not exists (
    select 1
    from ops.runtime_entity_audit
    where provider = 'api_american_football'
      and sport_code = 'AFB'
      and entity = 'fixtures'
);

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
  and entity = 'fixtures';