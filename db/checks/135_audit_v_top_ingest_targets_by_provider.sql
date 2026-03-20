SELECT
    provider,
    sport_code,
    run_group,
    COUNT(*) AS rows_count
FROM ops.v_top_ingest_targets
GROUP BY provider, sport_code, run_group
ORDER BY provider, sport_code, run_group;