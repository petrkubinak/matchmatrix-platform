SELECT
    t.run_group,
    COUNT(*) AS cnt
FROM ops.ingest_targets t
WHERE t.sport_code = 'FB'
GROUP BY t.run_group
ORDER BY t.run_group;