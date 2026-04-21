-- 728_insert_runtime_entity_audit_ck_skeleton.sql

-- =========================================================
-- CK TEAMS
-- =========================================================
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
    next_action,
    audit_note,
    created_at,
    updated_at
)
values (
    'api_sport',
    'CK',
    'teams',
    'PLANNED',
    'CK teams zatim neimplementovany.',
    false, false, false,
    false, false, false,
    false, false, false,
    'Navrhnout CK teams ingest (pull -> raw -> staging -> provider_map -> public)',
    'Inicialni skeleton pro CK.',
    now(),
    now()
);

-- =========================================================
-- CK FIXTURES
-- =========================================================
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
    next_action,
    audit_note,
    created_at,
    updated_at
)
values (
    'api_sport',
    'CK',
    'fixtures',
    'PLANNED',
    'CK fixtures zatim neimplementovany.',
    false, false, false,
    false, false, false,
    false, false, false,
    'Navrhnout CK fixtures ingest (pull -> raw -> staging -> public.matches)',
    'Inicialni skeleton pro CK.',
    now(),
    now()
);

-- =========================================================
-- CK LEAGUES
-- =========================================================
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
    next_action,
    audit_note,
    created_at,
    updated_at
)
values (
    'api_sport',
    'CK',
    'leagues',
    'PLANNED',
    'CK leagues zatim neimplementovany.',
    false, false, false,
    false, false, false,
    false, false, false,
    'Navrhnout CK leagues ingest (pull -> raw -> staging -> public.leagues)',
    'Inicialni skeleton pro CK.',
    now(),
    now()
);