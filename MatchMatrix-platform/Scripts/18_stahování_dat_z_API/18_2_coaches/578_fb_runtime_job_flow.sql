-- 578_fb_runtime_job_flow.sql
-- Účel:
-- potvrdit reálnou FB execution cestu v OPS vrstvě
-- Spouštět v DBeaveru

-- 1) FB job catalog
select *
from ops.v_fb_job_catalog
order by 1, 2, 3;

-- 2) FB orchestrator test mode
select *
from ops.v_fb_test_mode_orchestrator
order by 1, 2, 3;

-- 3) Harvest E2E control - jen FB
select *
from ops.v_harvest_e2e_control
where coalesce(sport_code, '') in ('FB', 'football')
   or coalesce(provider, '') in ('api_football', 'football_data', 'theodds')
order by 1, 2, 3;

-- 4) Poslední FB job runs
select *
from ops.job_runs
where coalesce(provider, '') in ('api_football', 'football_data', 'theodds')
   or coalesce(sport_code, '') in ('FB', 'football')
order by started_at desc nulls last
limit 50;