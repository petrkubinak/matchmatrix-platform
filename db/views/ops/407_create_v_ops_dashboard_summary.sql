-- 407_create_v_ops_dashboard_summary.sql
-- Dashboard KPI summary pro panel V9

create or replace view ops.v_ops_dashboard_summary as
with panel as (
    select
        provider,
        sport_code,
        entity,
        queue_action,
        panel_can_run,
        pending_cnt,
        running_cnt,
        done_cnt,
        error_cnt,
        skipped_cnt,
        total_targets,
        enabled_targets
    from ops.v_panel_run_control
),
agg as (
    select
        count(*)::int as total_rows,

        count(*) filter (where queue_action = 'RUN_NOW')::int       as run_now_rows,
        count(*) filter (where queue_action = 'RUN_VALIDATE')::int  as validate_rows,
        count(*) filter (where queue_action = 'MONITOR')::int       as monitor_rows,
        count(*) filter (where queue_action = 'REVIEW')::int        as review_rows,
        count(*) filter (where queue_action = 'WAIT_PLAN')::int     as wait_plan_rows,
        count(*) filter (where queue_action = 'BLOCKED')::int       as blocked_rows,

        count(*) filter (where panel_can_run is true)::int          as can_run_rows,
        count(*) filter (where panel_can_run is false)::int         as cannot_run_rows,

        coalesce(sum(pending_cnt), 0)::bigint as pending_total,
        coalesce(sum(running_cnt), 0)::bigint as running_total,
        coalesce(sum(done_cnt), 0)::bigint    as done_total,
        coalesce(sum(error_cnt), 0)::bigint   as error_total,
        coalesce(sum(skipped_cnt), 0)::bigint as skipped_total,

        coalesce(sum(total_targets), 0)::bigint   as total_targets_sum,
        coalesce(sum(enabled_targets), 0)::bigint as enabled_targets_sum,

        coalesce(sum(pending_cnt) filter (where queue_action = 'RUN_NOW'), 0)::bigint      as pending_run_now,
        coalesce(sum(pending_cnt) filter (where queue_action = 'RUN_VALIDATE'), 0)::bigint as pending_validate,
        coalesce(sum(pending_cnt) filter (where queue_action = 'REVIEW'), 0)::bigint       as pending_review,
        coalesce(sum(pending_cnt) filter (where queue_action = 'BLOCKED'), 0)::bigint      as pending_blocked
    from panel
),
budget as (
    select
        coalesce(sum(requests_used), 0)::bigint      as requests_used,
        coalesce(sum(requests_limit), 0)::bigint     as requests_limit,
        coalesce(sum(requests_remaining), 0)::bigint as requests_remaining
    from ops.v_api_budget_today
    where enabled is true
),
locks as (
    select count(*)::int as active_worker_locks
    from ops.v_worker_locks_active
)
select
    now() as snapshot_ts,

    agg.total_rows,

    agg.run_now_rows,
    agg.validate_rows,
    agg.monitor_rows,
    agg.review_rows,
    agg.wait_plan_rows,
    agg.blocked_rows,

    agg.can_run_rows,
    agg.cannot_run_rows,

    agg.pending_total,
    agg.running_total,
    agg.done_total,
    agg.error_total,
    agg.skipped_total,

    agg.total_targets_sum,
    agg.enabled_targets_sum,

    agg.pending_run_now,
    agg.pending_validate,
    agg.pending_review,
    agg.pending_blocked,

    case
        when agg.total_rows = 0 then 0::numeric(6,2)
        else round((agg.run_now_rows::numeric / agg.total_rows::numeric) * 100, 2)
    end as pct_run_now,

    case
        when agg.total_rows = 0 then 0::numeric(6,2)
        else round((agg.can_run_rows::numeric / agg.total_rows::numeric) * 100, 2)
    end as pct_can_run,

    case
        when agg.total_rows = 0 then 0::numeric(6,2)
        else round((agg.blocked_rows::numeric / agg.total_rows::numeric) * 100, 2)
    end as pct_blocked,

    case
        when agg.total_targets_sum = 0 then 0::numeric(6,2)
        else round((agg.enabled_targets_sum::numeric / agg.total_targets_sum::numeric) * 100, 2)
    end as pct_enabled_targets,

    budget.requests_used,
    budget.requests_limit,
    budget.requests_remaining,

    case
        when budget.requests_limit = 0 then 0::numeric(6,2)
        else round((budget.requests_used::numeric / budget.requests_limit::numeric) * 100, 2)
    end as pct_budget_used,

    locks.active_worker_locks

from agg
cross join budget
cross join locks;