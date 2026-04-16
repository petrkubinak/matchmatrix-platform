-- 604_fb_coaches_worker_path_check.sql
-- Účel:
-- ověřit, jestli pro FB coaches chybí jen planner aktivace,
-- nebo i konkrétní worker / script cesta
-- Spouštět v DBeaveru

-- 1) coverage realita
select
    provider,
    sport_code,
    entity,
    coverage_status,
    source_endpoint,
    target_table,
    worker_script,
    limitations,
    next_action
from ops.provider_entity_coverage
where sport_code = 'FB'
  and entity = 'coaches';

-- 2) provider jobs
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
where sport_code = 'FB'
  and (
      endpoint_code in ('coaches', 'coachs')
      or job_code ilike '%coach%'
  )
order by provider, job_code;

-- 3) jobs tabulka - hledání coach runneru
select *
from ops.jobs
where lower(coalesce(job_code, '')) like '%coach%'
   or lower(coalesce(job_name, '')) like '%coach%'
order by 1;

-- 4) scheduler queue - jestli někdy coaches job šel do fronty
select *
from ops.scheduler_queue
where lower(coalesce(job_code, '')) like '%coach%'
order by 1 desc
limit 50;