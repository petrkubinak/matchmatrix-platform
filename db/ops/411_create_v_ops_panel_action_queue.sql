drop view if exists ops.v_ops_panel_action_queue;

create view ops.v_ops_panel_action_queue as
with base as (
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
            else 99
        end as action_rank
    from ops.v_panel_run_control
    where queue_action in ('RUN_NOW', 'RUN_VALIDATE')
      and is_enabled is true
      and panel_can_run is true
),
ranked as (
    select
        b.*,
        row_number() over (
            order by
                action_rank,
                pending_cnt desc,
                provider_priority asc nulls last,
                fetch_priority asc nulls last,
                merge_priority asc nulls last,
                sport_code,
                provider,
                entity
        ) as queue_order
    from base b
)
select
    provider,
    sport_code,
    entity,

    queue_action,
    panel_run_mode,
    panel_color,
    panel_status_label,

    planner_priority_band,
    provider_priority,
    fetch_priority,
    merge_priority,

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
    pro_harvest_candidate,

    last_attempt,
    next_run,
    notes,
    limitations,
    next_action,

    action_rank,
    queue_order
from ranked
order by queue_order;