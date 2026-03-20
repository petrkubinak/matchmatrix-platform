SELECT
    run_group,
    enabled,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT provider) AS providers_count,
    COUNT(DISTINCT canonical_league_id) AS canonical_leagues_count,
    COUNT(DISTINCT provider_league_id) AS provider_leagues_count
FROM ops.ingest_targets
WHERE sport_code = 'FB'
GROUP BY run_group, enabled
ORDER BY run_group, enabled;