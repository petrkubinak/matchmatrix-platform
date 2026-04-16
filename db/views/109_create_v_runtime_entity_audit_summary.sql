-- 109_create_v_runtime_entity_audit_summary.sql

CREATE OR REPLACE VIEW ops.v_runtime_entity_audit_summary AS
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    CASE
        WHEN current_state = 'CONFIRMED' THEN 1
        WHEN current_state = 'RUNNABLE' THEN 2
        WHEN current_state = 'PARTIAL' THEN 3
        WHEN current_state = 'PLANNED' THEN 4
        WHEN current_state = 'NOT_TESTED' THEN 5
        WHEN current_state = 'BLOCKED' THEN 6
        WHEN current_state = 'BROKEN' THEN 7
        ELSE 99
    END AS state_sort,
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
    next_action,
    state_reason,
    db_evidence_summary,
    last_log_summary,
    audit_note,
    updated_at
FROM ops.runtime_entity_audit;