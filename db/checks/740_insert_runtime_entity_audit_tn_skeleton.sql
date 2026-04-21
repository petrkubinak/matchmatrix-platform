-- 740_insert_runtime_entity_audit_tn_skeleton.sql

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
values
(
    'api_tennis',
    'TN',
    'players',
    'PLANNED',
    'TN players zatim neimplementovani.',
    false,false,false,false,false,false,false,false,false,
    'Navrhnout TN players ingest (pull -> raw -> staging -> provider_map -> public)',
    'Inicialni skeleton pro TN.',
    now(), now()
),
(
    'api_tennis',
    'TN',
    'fixtures',
    'PLANNED',
    'TN fixtures zatim neimplementovany.',
    false,false,false,false,false,false,false,false,false,
    'Navrhnout TN fixtures ingest (pull -> raw -> staging -> public.matches)',
    'Inicialni skeleton pro TN.',
    now(), now()
),
(
    'api_tennis',
    'TN',
    'leagues',
    'PLANNED',
    'TN leagues zatim neimplementovany.',
    false,false,false,false,false,false,false,false,false,
    'Navrhnout TN leagues ingest (pull -> raw -> staging -> public.leagues)',
    'Inicialni skeleton pro TN.',
    now(), now()
);