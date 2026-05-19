SELECT
    p.provider,
    p.sport_code,
    p.entity,
    p.run_group,
    p.status,
    COUNT(*) AS jobs,
    MIN(p.next_run) AS min_next_run,
    MAX(p.next_run) AS max_next_run
FROM ops.ingest_planner p
WHERE p.entity IN ('players', 'coaches', 'player_stats', 'player_season_stats')
  AND p.sport_code IN ('FB', 'AFB', 'BK', 'BSB', 'HB', 'HK', 'CK', 'RGB', 'VB', 'TN')
GROUP BY
    p.provider,
    p.sport_code,
    p.entity,
    p.run_group,
    p.status
ORDER BY
    p.sport_code,
    p.entity,
    p.run_group,
    p.status;