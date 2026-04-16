-- 584_hk_audit_start.sql
-- FIX verze (provider_jobs nemá entity)

-- 1) HK provider/entity status
select *
from ops.v_provider_entity_status
where coalesce(sport_code, '') = 'HK'
order by provider_priority, fetch_priority, merge_priority, provider, entity;

-- 2) HK provider jobs (FIX: místo entity použij job_code + endpoint_code)
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
where coalesce(sport_code, '') = 'HK'
order by provider, job_code, endpoint_code;

-- 3) HK ready queue
select *
from ops.v_run_ready_queue
where coalesce(sport_code, '') = 'HK'
order by provider_priority, fetch_priority, merge_priority, provider, entity;

-- 4) HK planner queue
select *
from ops.v_ingest_planner_queue
where coalesce(sport_code, '') = 'HK'
order by priority, provider, entity, provider_league_id, season
limit 100;