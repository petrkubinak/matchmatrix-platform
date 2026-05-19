SELECT
    provider,
    sport_code,
    entity,
    run_group,
    status,
    COUNT(*) AS jobs,
    COUNT(*) FILTER (WHERE next_run IS NOT NULL) AS runnable_now
FROM ops.ingest_planner
GROUP BY provider, sport_code, entity, run_group, status
ORDER BY sport_code, entity;