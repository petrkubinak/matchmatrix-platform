-- 586_vb_audit_start.sql
-- Účel:
-- začátek VB auditu: provider + entity + queue realita
-- Spouštět v DBeaveru

-- 1) VB provider/entity status
select *
from ops.v_provider_entity_status
where coalesce(sport_code, '') = 'VB'
order by provider_priority, fetch_priority, merge_priority, provider, entity;

-- 2) VB provider jobs
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
where coalesce(sport_code, '') = 'VB'
order by provider, job_code, endpoint_code;

-- 3) VB ready queue
select *
from ops.v_run_ready_queue
where coalesce(sport_code, '') = 'VB'
order by provider_priority, fetch_priority, merge_priority, provider, entity;

-- 4) VB planner queue
select *
from ops.v_ingest_planner_queue
where coalesce(sport_code, '') = 'VB'
order by priority, provider, entity, provider_league_id, season
limit 100;