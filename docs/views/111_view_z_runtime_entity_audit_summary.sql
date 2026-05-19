SELECT
    provider,
    sport_code,
    entity,
    current_state,
    last_run_group,
    next_action
FROM ops.v_runtime_entity_audit_summary
ORDER BY sport_code, state_sort, provider, entity;

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed
FROM ops.v_runtime_entity_audit_summary
ORDER BY sport_code, state_sort, provider, entity;

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    next_action
FROM ops.v_runtime_entity_audit_summary
WHERE current_state <> 'CONFIRMED'
ORDER BY sport_code, state_sort, provider, entity;