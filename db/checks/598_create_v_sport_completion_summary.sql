-- 598_create_v_sport_completion_summary.sql
-- Účel:
-- souhrnný pohled nad dokončeností sportů
-- Spouštět v DBeaveru

create or replace view ops.v_sport_completion_summary as
select
    sport_code,

    count(*) as entity_count,

    sum(case when current_status = 'DONE' then 1 else 0 end) as done_cnt,
    sum(case when current_status = 'PARTIAL' then 1 else 0 end) as partial_cnt,
    sum(case when current_status = 'VALIDATE' then 1 else 0 end) as validate_cnt,
    sum(case when current_status = 'REVIEW' then 1 else 0 end) as review_cnt,
    sum(case when current_status = 'BLOCKED' then 1 else 0 end) as blocked_cnt,
    sum(case when current_status = 'WAIT_PROVIDER' then 1 else 0 end) as wait_provider_cnt,

    sum(case when production_readiness = 'READY' then 1 else 0 end) as ready_cnt,
    sum(case when production_readiness = 'NEAR_READY' then 1 else 0 end) as near_ready_cnt,
    sum(case when production_readiness = 'NOT_READY' then 1 else 0 end) as not_ready_cnt,

    sum(case when layer_type = 'core' and production_readiness = 'READY' then 1 else 0 end) as core_ready_cnt,
    sum(case when layer_type = 'people' and production_readiness = 'READY' then 1 else 0 end) as people_ready_cnt,
    sum(case when layer_type = 'people' and production_readiness = 'NEAR_READY' then 1 else 0 end) as people_near_ready_cnt,
    sum(case when layer_type = 'people' and production_readiness = 'NOT_READY' then 1 else 0 end) as people_not_ready_cnt,

    case
        when sum(case when layer_type = 'core' and production_readiness = 'READY' then 1 else 0 end) >= 1
         and sum(case when production_readiness = 'NOT_READY' then 1 else 0 end) = 0
            then 'SPORT_READY'
        when sum(case when production_readiness in ('READY', 'NEAR_READY') then 1 else 0 end) >= 1
            then 'SPORT_NEAR_READY'
        else 'SPORT_NOT_READY'
    end as sport_readiness,

    min(priority_rank) as top_priority_rank
from ops.sport_completion_audit
group by sport_code;

-- kontrola
select *
from ops.v_sport_completion_summary
order by top_priority_rank, sport_code;