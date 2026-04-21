-- 730_insert_runtime_entity_audit_rgb_skeleton.sql

-- =========================================================
-- RGB TEAMS
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
    'RGB',
    'teams',
    'PLANNED',
    'RGB teams zatim neimplementovany.',
    false, false, false,
    false, false, false,
    false, false, false,
    'Navrhnout RGB teams ingest (pull -> raw -> staging -> provider_map -> public)',
    'Inicialni skeleton pro RGB.',
    now(),
    now()
);

-- =========================================================
-- RGB FIXTURES
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
    'RGB',
    'fixtures',
    'PLANNED',
    'RGB fixtures zatim neimplementovany.',
    false, false, false,
    false, false, false,
    false, false, false,
    'Navrhnout RGB fixtures ingest (pull -> raw -> staging -> public.matches)',
    'Inicialni skeleton pro RGB.',
    now(),
    now()
);

-- =========================================================
-- RGB LEAGUES
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
    'RGB',
    'leagues',
    'PLANNED',
    'RGB leagues zatim neimplementovany.',
    false, false, false,
    false, false, false,
    false, false, false,
    'Navrhnout RGB leagues ingest (pull -> raw -> staging -> public.leagues)',
    'Inicialni skeleton pro RGB.',
    now(),
    now()
);