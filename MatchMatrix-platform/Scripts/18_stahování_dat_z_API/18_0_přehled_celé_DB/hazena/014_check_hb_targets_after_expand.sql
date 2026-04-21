SELECT
    COUNT(*) AS hb_fixture_targets_count
FROM ops.ingest_targets
WHERE sport_code = 'HB'
  AND provider = 'api_handball'
  AND run_group = 'HB_CORE'
  AND season = '2024'
  AND enabled = true;

SELECT
    tier,
    COUNT(*) AS cnt
FROM ops.ingest_targets
WHERE sport_code = 'HB'
  AND provider = 'api_handball'
  AND run_group = 'HB_CORE'
  AND season = '2024'
GROUP BY tier
ORDER BY tier;