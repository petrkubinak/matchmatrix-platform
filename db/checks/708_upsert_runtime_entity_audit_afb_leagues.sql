-- 708_upsert_runtime_entity_audit_afb_leagues.sql
-- AFB leagues - insert/update do ops.runtime_entity_audit
-- Spoustet v DBeaveru

update ops.runtime_entity_audit
set
    current_state = 'CONFIRMED',
    state_reason = 'AFB leagues jsou potvrzene v canonical vrstve pres public.leagues + ingest target NFL',
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
    last_log_summary = 'AFB league readiness potvrzena: NFL canonical league + ingest target existuji a fixtures jsou napojene.',
    db_evidence_summary = 'public.leagues ext_source=api_american_football ext_league_id=1 -> NFL | ops.ingest_targets AFB_CORE exists | public.matches api_american_football=335',
    next_action = 'Uzavrit AFB ve sport_completion_audit.',
    audit_note = 'AFB leagues jsou potvrzene pres existujici canonical NFL ligu a navazany fixtures merge.',
    updated_at = now()
where provider = 'api_american_football'
  and sport_code = 'AFB'
  and entity = 'leagues';

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
    'leagues',
    'CONFIRMED',
    'AFB leagues jsou potvrzene v canonical vrstve pres public.leagues + ingest target NFL',
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
    'AFB league readiness potvrzena: NFL canonical league + ingest target existuji a fixtures jsou napojene.',
    'public.leagues ext_source=api_american_football ext_league_id=1 -> NFL | ops.ingest_targets AFB_CORE exists | public.matches api_american_football=335',
    'Uzavrit AFB ve sport_completion_audit.',
    'AFB leagues jsou potvrzene pres existujici canonical NFL ligu a navazany fixtures merge.',
    now(),
    now()
where not exists (
    select 1
    from ops.runtime_entity_audit
    where provider = 'api_american_football'
      and sport_code = 'AFB'
      and entity = 'leagues'
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
  and entity = 'leagues';