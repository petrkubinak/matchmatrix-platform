-- 721_audit_hb_planner_queue.sql
-- Audit: proc planner negeneruje HB jobs

-- 1) ingest targets pro HB
SELECT
    'ingest_targets' AS src,
    t.id,
    t.sport_code,
    t.provider,
    t.provider_league_id,
    t.season,
    t.enabled,
    t.run_group
FROM ops.ingest_targets t
WHERE t.sport_code = 'HB'
ORDER BY t.provider_league_id;

-- 2) ingest entity plan pro HB fixtures
SELECT
    'ingest_entity_plan' AS src,
    p.id,
    p.provider,
    p.sport_code,
    p.entity,
    p.enabled,
    p.default_run_group,
    p.scope_type,
    p.requires_league,
    p.requires_season
FROM ops.ingest_entity_plan p
WHERE p.provider = 'api_handball'
  AND p.sport_code = 'HB'
  AND p.entity = 'fixtures';

-- 3) provider coverage pro HB fixtures
SELECT
    'provider_entity_coverage' AS src,
    c.id,
    c.provider,
    c.sport_code,
    c.entity,
    c.coverage_status,
    c.is_enabled,
    c.is_primary_source,
    c.is_merge_source
FROM ops.provider_entity_coverage c
WHERE c.provider = 'api_handball'
  AND c.sport_code = 'HB'
  AND c.entity = 'fixtures';

-- 4) runtime audit pro HB fixtures
SELECT
    'runtime_entity_audit' AS src,
    a.id,
    a.provider,
    a.sport_code,
    a.entity,
    a.current_state,
    a.panel_runner_exists,
    a.planner_target_exists,
    a.batch_target_exists,
    a.last_run_group
FROM ops.runtime_entity_audit a
WHERE a.provider = 'api_handball'
  AND a.sport_code = 'HB'
  AND a.entity = 'fixtures';

-- 5) existuje ops.ingest_planner?
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'ops'
  AND table_name IN ('ingest_planner', 'provider_jobs');

-- 6) pokud existuje ops.ingest_planner, zobraz strukturu
SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name IN ('ingest_planner', 'provider_jobs')
ORDER BY table_name, ordinal_position;