-- 716_check_hb_planner_source.sql
-- Cíl:
-- Ověřit, proč panel/planner nevidí HB teams joby,
-- i když HB ingest_targets existují.

-- =========================================================
-- 1) HB ingest targets
-- =========================================================
SELECT
    id,
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    enabled,
    tier,
    run_group,
    notes,
    created_at,
    updated_at
FROM ops.ingest_targets
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
ORDER BY tier, provider_league_id, season;

-- =========================================================
-- 2) HB planner source - ops.league_import_plan
-- =========================================================
SELECT
    provider,
    provider_league_id,
    sport_code,
    season,
    enabled,
    tier,
    fixtures_days_back,
    fixtures_days_forward,
    odds_days_forward,
    max_requests_per_run,
    notes,
    created_at,
    updated_at
FROM ops.league_import_plan
WHERE provider = 'api_handball'
ORDER BY sport_code, provider_league_id, season;

-- =========================================================
-- 3) Poslední planner/job runs pro HB
-- =========================================================
SELECT
    id,
    job_code,
    started_at,
    finished_at,
    status,
    params,
    message,
    details,
    rows_affected,
    created_at
FROM ops.job_runs
WHERE
    params::text ILIKE '%api_handball%'
    OR params::text ILIKE '%"HB"%'
    OR params::text ILIKE '%handball%'
ORDER BY id DESC
LIMIT 100;

-- =========================================================
-- 4) Jobs katalog
-- =========================================================
SELECT
    code,
    name,
    description,
    recommended,
    enabled,
    default_params,
    created_at,
    updated_at
FROM ops.jobs
ORDER BY code;