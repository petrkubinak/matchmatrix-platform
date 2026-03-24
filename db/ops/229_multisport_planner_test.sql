-- ============================================
-- 229_multisport_planner_test.sql
-- MatchMatrix
-- Test multisport planner připravenosti
-- Bez zásahu do produkčních jobů
-- ============================================

-- 1) kontrola mapování entity -> default_run_group
select
    sport_code,
    provider,
    entity,
    default_run_group,
    enabled,
    priority
from ops.ingest_entity_plan
where sport_code in ('TN','MMA','VB','HB','BSB','RGB','CK','FH','AFB','ESP','DRT')
order by sport_code, provider, priority;

-- 2) kontrola provider_jobs pro stejné sporty
select
    provider,
    sport_code,
    job_code,
    endpoint_code,
    ingest_mode,
    enabled,
    priority
from ops.provider_jobs
where sport_code in ('TN','MMA','VB','HB','BSB','RGB','CK','FH','AFB','ESP','DRT')
order by sport_code, priority, job_code;

-- 3) kontrola ingest_targets - zda už pro sporty existují cíle
select
    provider,
    sport_code,
    run_group,
    count(*) as target_count,
    sum(case when enabled then 1 else 0 end) as enabled_count
from ops.ingest_targets
where sport_code in ('TN','MMA','VB','HB','BSB','RGB','CK','FH','AFB','ESP','DRT')
group by provider, sport_code, run_group
order by sport_code, provider, run_group;

-- 4) sporty bez targetů = sporty, kde bude další krok seed targetů
select
    p.sport_code,
    count(t.*) as target_rows
from (
    select distinct sport_code
    from ops.ingest_entity_plan
    where sport_code in ('TN','MMA','VB','HB','BSB','RGB','CK','FH','AFB','ESP','DRT')
) p
left join ops.ingest_targets t
    on t.sport_code = p.sport_code
group by p.sport_code
order by p.sport_code;