-- 214_check_fb_bootstrap_after_first_run.sql

SELECT
    status,
    COUNT(*) AS jobs
FROM ops.ingest_planner
WHERE sport_code = 'FB'
  AND provider = 'api_football'
  AND run_group = 'FB_BOOTSTRAP_V1'
GROUP BY status
ORDER BY status;

SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    status,
    attempts,
    last_attempt,
    updated_at
FROM ops.ingest_planner
WHERE sport_code = 'FB'
  AND provider = 'api_football'
  AND run_group = 'FB_BOOTSTRAP_V1'
ORDER BY updated_at DESC
LIMIT 20;

SELECT
    id,
    job_code,
    status,
    started_at,
    finished_at,
    message
FROM ops.job_runs
ORDER BY id DESC
LIMIT 20;