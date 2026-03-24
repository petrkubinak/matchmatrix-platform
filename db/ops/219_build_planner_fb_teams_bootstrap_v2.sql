SELECT
    provider,
    sport_code,
    entity,
    run_group,
    status,
    COUNT(*) AS jobs
FROM ops.ingest_planner
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'teams'
GROUP BY provider, sport_code, entity, run_group, status
ORDER BY run_group, status;

SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    updated_at
FROM ops.ingest_planner
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'teams'
ORDER BY updated_at DESC
LIMIT 50;