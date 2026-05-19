BEGIN;

INSERT INTO ops.ingest_planner (
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run,
    created_at,
    updated_at
)
SELECT
    provider,
    sport_code,
    'players',
    provider_league_id,
    season,
    run_group,
    200,
    'pending',
    0,
    now(),
    now(),
    now()
FROM ops.ingest_targets
WHERE run_group = 'FB_PEOPLE_SCALE_01'
  AND enabled = true
ON CONFLICT DO NOTHING;

COMMIT;

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
    attempts
FROM ops.ingest_planner
WHERE run_group = 'FB_PEOPLE_SCALE_01'
ORDER BY provider_league_id::int;