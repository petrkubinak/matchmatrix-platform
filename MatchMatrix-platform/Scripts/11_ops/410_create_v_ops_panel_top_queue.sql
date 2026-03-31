drop view if exists ops.v_ops_panel_top_queue;

create view ops.v_ops_panel_top_queue as
select
    provider,
    sport_code,
    entity,

    queue_action,
    panel_can_run,
    panel_run_mode,
    panel_color,
    panel_status_label,

    planner_priority_band,
    provider_priority,
    fetch_priority,
    merge_priority,
    panel_sort_group,

    pending_cnt,
    running_cnt,
    done_cnt,
    error_cnt,
    skipped_cnt,

    total_targets,
    enabled_targets,

    coverage_status,
    runtime_status,
    quality_rating,
    expected_depth,
    availability_scope,

    is_primary_source,
    is_fallback_source,
    is_merge_source,
    is_enabled,
    pro_harvest_candidate,

    last_attempt,
    next_run,
    notes,
    limitations,
    next_action,

    case
        when queue_action = 'RUN_NOW' then 1
        when queue_action = 'RUN_VALIDATE' then 2
        when queue_action = 'MONITOR' then 3
        when queue_action = 'REVIEW' then 4
        when queue_action = 'WAIT_PLAN' then 5
        when queue_action = 'BLOCKED' then 6
        else 99
    end as queue_rank

from ops.v_panel_run_control
order by
    case
        when queue_action = 'RUN_NOW' then 1
        when queue_action = 'RUN_VALIDATE' then 2
        when queue_action = 'MONITOR' then 3
        when queue_action = 'REVIEW' then 4
        when queue_action = 'WAIT_PLAN' then 5
        when queue_action = 'BLOCKED' then 6
        else 99
    end,
    panel_can_run desc,
    pending_cnt desc,
    provider_priority asc nulls last,
    fetch_priority asc nulls last,
    merge_priority asc nulls last,
    sport_code,
    provider,
    entity;