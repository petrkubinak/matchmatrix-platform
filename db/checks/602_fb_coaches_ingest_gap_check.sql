-- 602_fb_coaches_ingest_gap_check.sql
-- Účel:
-- zjistit, jestli pro FB coaches existuje připravená ingest cesta
-- a kde přesně se tok zastavuje
-- Spouštět v DBeaveru

-- 1) provider coverage pro FB coaches
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

-- 2) provider jobs pro FB coaches
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

-- 3) planner queue pro FB coaches
select *
from ops.v_ingest_planner_queue
where sport_code = 'FB'
  and entity = 'coaches'
order by priority, provider, provider_league_id, season
limit 100;

-- 4) ready queue pro FB coaches
select *
from ops.v_run_ready_queue
where sport_code = 'FB'
  and entity = 'coaches';

-- 5) jestli už někdy něco spadlo do stagingu bez FB filtru
select
    provider,
    sport_code,
    count(*) as stg_rows
from staging.stg_provider_coaches
group by provider, sport_code
order by provider, sport_code;

-- 6) posledních pár řádků ze staging coaches
select *
from staging.stg_provider_coaches
order by created_at desc nulls last
limit 50;