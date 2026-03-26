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
    last_attempt,
    next_run,
    created_at,
    updated_at
FROM ops.ingest_planner
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity = 'teams'
ORDER BY id DESC;