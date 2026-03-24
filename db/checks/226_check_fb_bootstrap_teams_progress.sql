-- 226_check_fb_bootstrap_teams_progress.sql

SELECT
    status,
    attempts,
    COUNT(*) AS jobs
FROM ops.ingest_planner
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND run_group = 'FB_BOOTSTRAP_V1'
  AND entity = 'teams'
GROUP BY status, attempts
ORDER BY status, attempts;