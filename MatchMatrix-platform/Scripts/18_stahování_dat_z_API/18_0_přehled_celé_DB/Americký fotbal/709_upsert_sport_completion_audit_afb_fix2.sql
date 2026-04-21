-- 709_upsert_sport_completion_audit_afb_fix2.sql
-- AFB - finalni sport completion audit podle realne struktury tabulky

update ops.sport_completion_audit
set
    entity = 'core',
    layer_type = 'core_pipeline',
    current_status = 'DONE',
    production_readiness = 'READY',
    provider_primary = 'api_american_football',
    provider_fallback = null,
    db_layer_ready = true,
    planner_ready = true,
    queue_ready = true,
    public_ready = true,
    key_gap = null,
    next_step = 'AFB core pipeline uzavrena. Dalsi krok pripadne odds / people / downstream.',
    evidence_note = 'AFB teams CONFIRMED | AFB fixtures CONFIRMED | AFB leagues CONFIRMED | public.matches api_american_football=335',
    priority_rank = 90,
    updated_at = now()
where sport_code = 'AFB'
  and entity = 'core';

insert into ops.sport_completion_audit (
    sport_code,
    entity,
    layer_type,
    current_status,
    production_readiness,
    provider_primary,
    provider_fallback,
    db_layer_ready,
    planner_ready,
    queue_ready,
    public_ready,
    key_gap,
    next_step,
    evidence_note,
    priority_rank,
    created_at,
    updated_at
)
select
    'AFB',
    'core',
    'core_pipeline',
    'DONE',
    'READY',
    'api_american_football',
    null,
    true,
    true,
    true,
    true,
    null,
    'AFB core pipeline uzavrena. Dalsi krok pripadne odds / people / downstream.',
    'AFB teams CONFIRMED | AFB fixtures CONFIRMED | AFB leagues CONFIRMED | public.matches api_american_football=335',
    90,
    now(),
    now()
where not exists (
    select 1
    from ops.sport_completion_audit
    where sport_code = 'AFB'
      and entity = 'core'
);

select
    sport_code,
    entity,
    layer_type,
    current_status,
    production_readiness,
    provider_primary,
    db_layer_ready,
    planner_ready,
    queue_ready,
    public_ready,
    evidence_note
from ops.sport_completion_audit
where sport_code = 'AFB'
order by entity, layer_type;