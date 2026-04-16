-- 704_upsert_runtime_entity_audit_afb_teams.sql
-- AFB teams - insert/update do ops.runtime_entity_audit
-- Spoustet v DBeaveru

-- 1) nejdriv zkusime update
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

-- 2) pokud radek neexistoval, vlozime ho
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
    'teams',
    'CONFIRMED',
    'AFB teams end-to-end potvrzeno: pull -> raw -> staging -> provider_map -> public teams',
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
    'AFB teams pull OK | RAW saved | parser OK | merge to public.teams OK',
    'stg_api_american_football_teams=34 | public.teams ext_source=api_american_football=34 | team_provider_map api_american_football=34',
    'Pripravit AFB fixtures pipeline stejnym patternem.',
    'AFB teams jsou potvrzene v canonical public vrstve. Pozdeji zvazit filtraci konferencnich entit AFC/NFC.',
    now(),
    now()
where not exists (
    select 1
    from ops.runtime_entity_audit
    where provider = 'api_american_football'
      and sport_code = 'AFB'
      and entity = 'teams'
);

-- 3) kontrola
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