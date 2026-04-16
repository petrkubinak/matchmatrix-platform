-- 590_inspect_people_provider_candidates.sql (FINAL FOR YOUR DB)

-- 1) Provider/entity přehled (co je vůbec k dispozici)
select
    provider,
    sport_code,
    entity,
    coverage_status,
    quality_rating,
    availability_scope,
    expected_depth,
    is_primary_source,
    is_enabled,
    provider_priority
from ops.v_provider_entity_status
where entity in ('players', 'coaches')
order by sport_code, provider_priority desc;

------------------------------------------------------------

-- 2) Provider jobs – realita endpointů
select
    provider,
    sport_code,
    job_code,
    endpoint_code,
    enabled,
    priority,
    batch_size,
    max_requests_per_run,
    cooldown_seconds
from ops.provider_jobs
where endpoint_code in ('players', 'coaches', 'coachs')
   or job_code ilike '%players%'
   or job_code ilike '%coach%'
order by sport_code, provider, job_code;

------------------------------------------------------------

-- 3) PEOPLE AUDIT – klíčová realita
select
    provider,
    sport_code,
    entity,
    endpoint_name,
    endpoint_exists,
    endpoint_tested,
    endpoint_returns_data,
    technical_status,
    data_quality_status,
    final_verdict,
    alternative_provider_needed,
    next_step
from ops.provider_people_audit
order by sport_code, provider, entity;

------------------------------------------------------------

-- 4) AGREGACE – rozhodovací pohled
select
    sport_code,
    entity,
    count(*) as total_rows,
    sum(case when final_verdict = 'USABLE' then 1 else 0 end) as usable_cnt,
    sum(case when final_verdict = 'PARTIAL_ONLY' then 1 else 0 end) as partial_cnt,
    sum(case when final_verdict = 'BLOCKED' then 1 else 0 end) as blocked_cnt,
    sum(case when final_verdict = 'WAIT_PROVIDER' then 1 else 0 end) as wait_provider_cnt
from ops.provider_people_audit
group by sport_code, entity
order by sport_code, entity;