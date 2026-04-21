-- 008_check_hb_planner_vs_targets.sql

-- 1) HB ingest targets pro fixtures
SELECT
    COUNT(*) AS hb_fixture_targets_count
FROM ops.ingest_targets
WHERE sport_code = 'HB'
  AND provider = 'api_handball'
  AND run_group = 'HB_CORE'
  AND enabled = true;

-- 2) detail targetů
SELECT
    id,
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    enabled,
    run_group,
    notes
FROM ops.ingest_targets
WHERE sport_code = 'HB'
  AND provider = 'api_handball'
  AND run_group = 'HB_CORE'
  AND enabled = true
ORDER BY provider_league_id::int, season;

-- 3) planner pending jobs pro HB fixtures
SELECT
    COUNT(*) AS hb_fixture_pending_jobs_count
FROM ops.ingest_planner
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'fixtures'
  AND run_group = 'HB_CORE'
  AND status = 'pending';

-- 4) detail planneru
SELECT
    id,
    provider,
    sport_code,
    entity,
    target_id,
    run_group,
    status,
    attempts,
    created_at,
    started_at,
    finished_at,
    payload
FROM ops.ingest_planner
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'fixtures'
  AND run_group = 'HB_CORE'
ORDER BY id DESC;