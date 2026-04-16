-- 604B_fb_coaches_job_binding_check.sql
-- Účel:
-- ověřit, jestli FB coaches mají job definici a jestli se propsaly do scheduler queue
-- Spouštět v DBeaveru

-- 1) jobs definice pro coach/coaches
select
    code,
    name,
    description,
    recommended,
    enabled,
    default_params,
    created_at,
    updated_at
from ops.jobs
where lower(coalesce(code, '')) like '%coach%'
   or lower(coalesce(name, '')) like '%coach%'
   or lower(coalesce(description, '')) like '%coach%'
order by code;

-- 2) scheduler queue pro FB + api_football + coach related run groups
select
    id,
    queue_day,
    sport_code,
    target_id,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    tier,
    run_group,
    max_requests_per_run,
    status,
    selected_by,
    selected_at,
    started_at,
    finished_at,
    message
from ops.scheduler_queue
where sport_code = 'FB'
  and provider = 'api_football'
  and run_group in ('FB_TOP', 'FB_API_EXPANSION', 'FB_BOOTSTRAP_V1', 'FOOTBALL_MAINTENANCE')
order by id desc
limit 100;

-- 3) jen kontrola, jestli se v message někde neobjeví coach
select
    id,
    queue_day,
    provider,
    run_group,
    status,
    message
from ops.scheduler_queue
where sport_code = 'FB'
  and provider = 'api_football'
  and lower(coalesce(message, '')) like '%coach%'
order by id desc
limit 50;