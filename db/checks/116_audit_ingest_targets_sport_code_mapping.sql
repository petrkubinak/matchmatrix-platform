SELECT
    sport_code,
    COUNT(*) AS rows_count,
    COUNT(*) FILTER (WHERE enabled = TRUE) AS enabled_count,
    COUNT(DISTINCT provider) AS providers_count,
    MIN(run_group) AS sample_run_group
FROM ops.ingest_targets
GROUP BY sport_code
ORDER BY sport_code;