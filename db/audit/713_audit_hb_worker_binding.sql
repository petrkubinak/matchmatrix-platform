-- 713_audit_hb_worker_binding.sql
-- Účel:
-- Najít všechny reálné odkazy na HB worker / runner / provider napojení v OPS.

-- =========================================================
-- A) provider_entity_coverage -> worker_script
-- =========================================================
select
    'provider_entity_coverage' as source_table,
    provider,
    sport_code,
    entity,
    worker_script,
    target_table,
    source_endpoint,
    next_action,
    notes
from ops.provider_entity_coverage
where upper(sport_code) = 'HB'
order by provider, entity;

-- =========================================================
-- B) ingest_entity_plan -> worker_script
-- =========================================================
select
    'ingest_entity_plan' as source_table,
    provider,
    sport_code,
    entity,
    worker_script,
    target_table,
    source_endpoint,
    default_run_group,
    notes
from ops.ingest_entity_plan
where upper(sport_code) = 'HB'
order by provider, entity;

-- =========================================================
-- C) provider_jobs
-- Bez znalosti přesné struktury přes to_jsonb
-- =========================================================
select
    'provider_jobs' as source_table,
    to_jsonb(pj) as row_data
from ops.provider_jobs pj
where upper(coalesce(pj.sport_code, '')) = 'HB'
   or upper(coalesce(pj.provider, '')) = 'API_HANDBALL';

-- =========================================================
-- D) jobs
-- Bez znalosti přesné struktury přes to_jsonb
-- =========================================================
select
    'jobs' as source_table,
    to_jsonb(j) as row_data
from ops.jobs j
where upper(to_jsonb(j)::text) like '%API_HANDBALL%'
   or upper(to_jsonb(j)::text) like '%"HB"%';

-- =========================================================
-- E) job_runs
-- poslední HB / api_handball běhy, pokud existují
-- =========================================================
select
    'job_runs' as source_table,
    to_jsonb(jr) as row_data
from ops.job_runs jr
where upper(to_jsonb(jr)::text) like '%API_HANDBALL%'
   or upper(to_jsonb(jr)::text) like '%"HB"%'
order by jr.started_at desc
limit 20;