-- 722_update_or_insert_sport_completion_audit_afb_core_done.sql

-- 1) nejdřív update existujícího řádku
update ops.sport_completion_audit
set
    current_status = 'DONE',
    production_readiness = 'READY',
    provider_primary = 'api_american_football',
    db_layer_ready = true,
    planner_ready = true,
    queue_ready = true,
    public_ready = true,
    evidence_note = 'AFB teams CONFIRMED | AFB fixtures CONFIRMED | AFB leagues CONFIRMED | public.matches api_american_football=335 | public.team_provider_map api_american_football=34 | public.leagues api_american_football=1',
    updated_at = now()
where sport_code = 'AFB'
  and layer_type = 'core'
  and entity = 'core_pipeline';

-- 2) pokud řádek neexistuje, vlož ho
insert into ops.sport_completion_audit (
    sport_code,
    layer_type,
    entity,
    current_status,
    production_readiness,
    provider_primary,
    db_layer_ready,
    planner_ready,
    queue_ready,
    public_ready,
    evidence_note,
    updated_at
)
select
    'AFB',
    'core',
    'core_pipeline',
    'DONE',
    'READY',
    'api_american_football',
    true,
    true,
    true,
    true,
    'AFB teams CONFIRMED | AFB fixtures CONFIRMED | AFB leagues CONFIRMED | public.matches api_american_football=335 | public.team_provider_map api_american_football=34 | public.leagues api_american_football=1',
    now()
where not exists (
    select 1
    from ops.sport_completion_audit
    where sport_code = 'AFB'
      and layer_type = 'core'
      and entity = 'core_pipeline'
);