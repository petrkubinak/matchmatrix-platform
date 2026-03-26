-- 034_check_bk_fixtures_planner.sql

SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    status,
    attempts,
    priority,
    run_group,
    updated_at
FROM ops.ingest_planner
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'fixtures'
ORDER BY run_group, priority, id;

SELECT
    provider,
    sport_code,
    entity,
    run_group,
    status,
    COUNT(*) AS cnt
FROM ops.ingest_planner
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'fixtures'
GROUP BY provider, sport_code, entity, run_group, status
ORDER BY run_group, status;