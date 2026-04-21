-- =========================================================
-- 139_ops_audit_tn_update.sql
-- MATCHMATRIX - OPS AUDIT UPDATE (TN)
-- =========================================================

begin;

-- =========================================================
-- 1) TN LEAGUES (PARTIAL)
-- =========================================================

update ops.runtime_entity_audit
set
    current_state = 'PARTIAL',
    state_reason = 'TN leagues jsou funkční jako seed/search vrstva.',
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    public_merge_confirmed = true,
    last_run_group = 'TN_CORE',
    last_check_at = now(),
    updated_at = now()
where provider = 'api_tennis'
  and sport_code = 'TN'
  and entity = 'leagues';

insert into ops.runtime_entity_audit (
    provider, sport_code, entity,
    current_state, state_reason,
    pull_confirmed, raw_confirmed, staging_confirmed, public_merge_confirmed,
    last_run_group, last_check_at
)
select
    'api_tennis', 'TN', 'leagues',
    'PARTIAL', 'TN leagues jsou funkční jako seed/search vrstva.',
    true, true, true, true,
    'TN_CORE', now()
where not exists (
    select 1
    from ops.runtime_entity_audit
    where provider = 'api_tennis'
      and sport_code = 'TN'
      and entity = 'leagues'
);

-- =========================================================
-- 2) TN TEAMS (CONFIRMED)
-- =========================================================

update ops.runtime_entity_audit
set
    current_state = 'CONFIRMED',
    state_reason = 'TN players mapovaní jako teams.',
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    last_run_group = 'TN_CORE',
    last_check_at = now(),
    updated_at = now()
where provider = 'api_tennis'
  and sport_code = 'TN'
  and entity = 'teams';

insert into ops.runtime_entity_audit (
    provider, sport_code, entity,
    current_state, state_reason,
    provider_map_confirmed, public_merge_confirmed,
    last_run_group, last_check_at
)
select
    'api_tennis', 'TN', 'teams',
    'CONFIRMED', 'TN players mapovaní jako teams.',
    true, true,
    'TN_CORE', now()
where not exists (
    select 1
    from ops.runtime_entity_audit
    where provider = 'api_tennis'
      and sport_code = 'TN'
      and entity = 'teams'
);

-- =========================================================
-- 3) TN FIXTURES (CONFIRMED)
-- =========================================================

update ops.runtime_entity_audit
set
    current_state = 'CONFIRMED',
    state_reason = 'TN fixtures jsou v public.matches.',
    public_merge_confirmed = true,
    downstream_confirmed = true,
    last_run_group = 'TN_CORE',
    last_check_at = now(),
    updated_at = now()
where provider = 'api_tennis'
  and sport_code = 'TN'
  and entity = 'fixtures';

insert into ops.runtime_entity_audit (
    provider, sport_code, entity,
    current_state, state_reason,
    public_merge_confirmed, downstream_confirmed,
    last_run_group, last_check_at
)
select
    'api_tennis', 'TN', 'fixtures',
    'CONFIRMED', 'TN fixtures jsou v public.matches.',
    true, true,
    'TN_CORE', now()
where not exists (
    select 1
    from ops.runtime_entity_audit
    where provider = 'api_tennis'
      and sport_code = 'TN'
      and entity = 'fixtures'
);

-- =========================================================
-- 4) TN ODDS (CONFIRMED)
-- =========================================================

update ops.runtime_entity_audit
set
    current_state = 'CONFIRMED',
    state_reason = 'TN odds pipeline funguje (RAW -> parser -> public.odds).',
    raw_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = true,
    last_run_group = 'TN_CORE',
    last_run_at = now(),
    last_check_at = now(),
    updated_at = now()
where provider = 'api_tennis'
  and sport_code = 'TN'
  and entity = 'odds';

insert into ops.runtime_entity_audit (
    provider, sport_code, entity,
    current_state, state_reason,
    raw_confirmed, public_merge_confirmed, downstream_confirmed,
    last_run_group, last_run_at, last_check_at
)
select
    'api_tennis', 'TN', 'odds',
    'CONFIRMED', 'TN odds pipeline funguje (RAW -> parser -> public.odds).',
    true, true, true,
    'TN_CORE', now(), now()
where not exists (
    select 1
    from ops.runtime_entity_audit
    where provider = 'api_tennis'
      and sport_code = 'TN'
      and entity = 'odds'
);

-- =========================================================
-- 5) TN SPORT COMPLETION AUDIT
-- =========================================================

update ops.sport_completion_audit
set
    current_status = 'DONE',
    production_readiness = 'READY',
    provider_primary = 'api_tennis',
    db_layer_ready = true,
    public_ready = true,
    updated_at = now()
where sport_code = 'TN'
  and entity = 'core'
  and layer_type = 'core_pipeline';

insert into ops.sport_completion_audit (
    sport_code, entity, layer_type,
    current_status, production_readiness,
    provider_primary, db_layer_ready, public_ready
)
select
    'TN', 'core', 'core_pipeline',
    'DONE', 'READY',
    'api_tennis', true, true
where not exists (
    select 1
    from ops.sport_completion_audit
    where sport_code = 'TN'
      and entity = 'core'
      and layer_type = 'core_pipeline'
);

commit;

-- =========================================================
-- KONTROLA
-- =========================================================

select provider, sport_code, entity, current_state
from ops.runtime_entity_audit
where provider = 'api_tennis'
  and sport_code = 'TN'
order by entity;

select sport_code, entity, layer_type, current_status
from ops.sport_completion_audit
where sport_code = 'TN';