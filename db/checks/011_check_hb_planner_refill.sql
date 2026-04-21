SELECT
    status,
    COUNT(*) AS cnt
FROM ops.ingest_planner
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'fixtures'
  AND run_group = 'HB_CORE'
GROUP BY status
ORDER BY status;

SELECT
    COUNT(*) AS hb_pending_fixture_jobs
FROM ops.ingest_planner
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'fixtures'
  AND run_group = 'HB_CORE'
  AND status = 'pending';