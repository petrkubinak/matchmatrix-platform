-- 714_seed_runtime_entity_audit_hb_core_fix2.sql
-- Účel:
-- Založit runtime audit řádky pro HB core entity:
-- leagues / teams / fixtures
-- Stav: OPS exists, runtime chain not tested yet.

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
    x.provider,
    x.sport_code,
    x.entity,
    'NOT_TESTED' as current_state,
    'HB exists in OPS tables, but worker_script is empty and runtime execution chain has not been tested yet.' as state_reason,
    false as panel_runner_exists,
    exists (
        select 1
        from ops.ingest_entity_plan iep
        where iep.provider = x.provider
          and iep.sport_code = x.sport_code
          and iep.entity = x.entity
          and iep.enabled = true
    ) as planner_target_exists,
    exists (
        select 1
        from ops.ingest_targets it
        where it.provider = x.provider
          and it.sport_code = x.sport_code
          and it.enabled = true
    ) as batch_target_exists,
    false as pull_confirmed,
    false as raw_confirmed,
    false as staging_confirmed,
    false as provider_map_confirmed,
    false as public_merge_confirmed,
    false as downstream_confirmed,
    'HB_CORE' as last_run_group,
    null as last_run_at,
    now() as last_check_at,
    'HB core seeded into runtime audit; waiting for first worker binding and first test run.' as last_log_summary,
    'OPS rows exist for HB core. worker_script empty in OPS. ingest_targets available for HB.' as db_evidence_summary,
    'Build HB core execution chain for leagues, teams, fixtures via reusable multisport pattern.' as next_action,
    'Seeded from 714_seed_runtime_entity_audit_hb_core_fix2.sql' as audit_note,
    now() as created_at,
    now() as updated_at
from (
    values
        ('api_handball', 'HB', 'leagues'),
        ('api_handball', 'HB', 'teams'),
        ('api_handball', 'HB', 'fixtures')
) as x(provider, sport_code, entity)
where not exists (
    select 1
    from ops.runtime_entity_audit rea
    where rea.provider = x.provider
      and rea.sport_code = x.sport_code
      and rea.entity = x.entity
);

-- Kontrola výsledku
select
    provider,
    sport_code,
    entity,
    current_state,
    planner_target_exists,
    batch_target_exists,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    last_run_group,
    next_action
from ops.runtime_entity_audit
where upper(sport_code) = 'HB'
order by provider, entity;