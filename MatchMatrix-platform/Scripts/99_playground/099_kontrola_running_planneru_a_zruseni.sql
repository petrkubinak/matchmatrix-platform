SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    status,
    attempts,
    last_attempt,
    updated_at
FROM ops.ingest_planner
WHERE status = 'running'
ORDER BY updated_at;

UPDATE ops.ingest_planner
SET
    status = 'pending',
    updated_at = NOW()
WHERE status = 'running'
  AND updated_at < NOW() - interval '10 minutes';