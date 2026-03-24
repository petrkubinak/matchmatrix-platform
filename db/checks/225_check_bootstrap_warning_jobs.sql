-- 225_check_bootstrap_warning_jobs.sql

SELECT
    provider,
    sport_code,
    entity,
    run_group,
    status,
    attempts,
    COUNT(*) AS jobs
FROM ops.ingest_planner
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND run_group = 'FB_BOOTSTRAP_V1'
  AND entity IN ('fixtures', 'teams')
GROUP BY provider, sport_code, entity, run_group, status, attempts
ORDER BY entity, status, attempts;

SELECT
    id,
    entity,
    provider_league_id,
    season,
    status,
    attempts,
    last_attempt,
    updated_at
FROM ops.ingest_planner
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND run_group = 'FB_BOOTSTRAP_V1'
  AND entity IN ('fixtures', 'teams')
  AND attempts > 0
ORDER BY updated_at DESC
LIMIT 50;