SELECT
    sport_code,
    run_group,
    COUNT(*) AS rows_count,
    COUNT(DISTINCT canonical_league_id) AS canonical_leagues_count,
    COUNT(DISTINCT provider_league_id) AS provider_leagues_count
FROM ops.ingest_targets
WHERE run_group IN (
    'FOOTBALL_MAINTENANCE_TOP',
    'BK_MAINTENANCE_TOP',
    'HK_MAINTENANCE_TOP'
)
GROUP BY sport_code, run_group
ORDER BY sport_code, run_group;