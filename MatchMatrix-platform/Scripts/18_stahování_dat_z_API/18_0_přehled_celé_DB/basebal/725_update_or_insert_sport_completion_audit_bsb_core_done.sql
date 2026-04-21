-- 725_update_or_insert_sport_completion_audit_bsb_core_done.sql

-- 1) update správného řádku, pokud už existuje
update ops.sport_completion_audit
set
    current_status = 'DONE',
    production_readiness = 'READY',
    provider_primary = 'api_baseball',
    db_layer_ready = true,
    planner_ready = true,
    queue_ready = true,
    public_ready = true,
    evidence_note = 'BSB leagues CONFIRMED | BSB teams CONFIRMED | BSB fixtures CONFIRMED | public.leagues api_baseball=77 | public.team_provider_map api_baseball=30 | public.matches api_baseball=2945',
    updated_at = now()
where sport_code = 'BSB'
  and layer_type = 'core'
  and entity = 'core_pipeline';

-- 2) insert, pokud ještě neexistuje
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
    'BSB',
    'core',
    'core_pipeline',
    'DONE',
    'READY',
    'api_baseball',
    true,
    true,
    true,
    true,
    'BSB leagues CONFIRMED | BSB teams CONFIRMED | BSB fixtures CONFIRMED | public.leagues api_baseball=77 | public.team_provider_map api_baseball=30 | public.matches api_baseball=2945',
    now()
where not exists (
    select 1
    from ops.sport_completion_audit
    where sport_code = 'BSB'
      and layer_type = 'core'
      and entity = 'core_pipeline'
);