-- 739_insert_rgb_core_pipeline_simple.sql

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
    'api_rugby',
    'RGB',
    'core_pipeline',
    'CONFIRMED',
    'RGB core pipeline end-to-end potvrzeno (leagues + teams + fixtures).',
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    false,
    'RGB core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    'RGB leagues=142 | teams=6 | fixtures=15 | public.matches=15',
    now(),
    now()
);