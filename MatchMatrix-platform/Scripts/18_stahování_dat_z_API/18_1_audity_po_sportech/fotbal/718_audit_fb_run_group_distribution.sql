SELECT
    run_group,
    COUNT(*) AS cnt
FROM ops.ingest_targets
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND enabled = true
GROUP BY run_group
ORDER BY cnt DESC, run_group;