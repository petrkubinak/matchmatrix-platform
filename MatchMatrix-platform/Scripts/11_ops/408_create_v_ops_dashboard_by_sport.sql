drop view if exists ops.v_ops_dashboard_by_sport;

create view ops.v_ops_dashboard_by_sport as
select
    sport_code,

    count(*)::int as total_rows,

    count(*) filter (where queue_action = 'RUN_NOW')::int       as run_now_rows,
    count(*) filter (where queue_action = 'RUN_VALIDATE')::int  as validate_rows,
    count(*) filter (where queue_action = 'MONITOR')::int       as monitor_rows,
    count(*) filter (where queue_action = 'REVIEW')::int        as review_rows,
    count(*) filter (where queue_action = 'WAIT_PLAN')::int     as wait_plan_rows,
    count(*) filter (where queue_action = 'BLOCKED')::int       as blocked_rows,

    count(*) filter (where panel_can_run is true)::int  as can_run_rows,
    count(*) filter (where panel_can_run is false)::int as cannot_run_rows,

    coalesce(sum(pending_cnt), 0)::bigint as pending_total,
    coalesce(sum(running_cnt), 0)::bigint as running_total,
    coalesce(sum(done_cnt), 0)::bigint    as done_total,
    coalesce(sum(error_cnt), 0)::bigint   as error_total,
    coalesce(sum(skipped_cnt), 0)::bigint as skipped_total,

    coalesce(sum(total_targets), 0)::bigint   as total_targets_sum,
    coalesce(sum(enabled_targets), 0)::bigint as enabled_targets_sum,

    case
        when count(*) = 0 then 0::numeric(6,2)
        else round(
            (count(*) filter (where queue_action = 'RUN_NOW'))::numeric
            / count(*)::numeric * 100, 2
        )
    end as pct_run_now,

    case
        when count(*) = 0 then 0::numeric(6,2)
        else round(
            (count(*) filter (where panel_can_run is true))::numeric
            / count(*)::numeric * 100, 2
        )
    end as pct_can_run,

    case
        when coalesce(sum(total_targets), 0) = 0 then 0::numeric(6,2)
        else round(
            coalesce(sum(enabled_targets), 0)::numeric
            / sum(total_targets)::numeric * 100, 2
        )
    end as pct_enabled_targets

from ops.v_panel_run_control
group by sport_code
order by
    pending_total desc,
    sport_code;