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
    it.provider,
    'FB' AS sport_code,
    'players' AS entity,
    it.provider_league_id,
    it.season,
    'FB_PEOPLE_AUTO_2024' AS run_group,
    100 AS priority,
    'pending' AS status,
    0 AS attempts,
    now() AS next_run,
    now() AS created_at,
    now() AS updated_at
FROM ops.ingest_targets it
WHERE it.provider = 'api_football'
  AND it.sport_code = 'FB'
  AND it.season = '2024'
  AND it.enabled = true
  AND it.provider_league_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner ip
      WHERE ip.provider = 'api_football'
        AND ip.sport_code = 'FB'
        AND ip.entity = 'players'
        AND ip.provider_league_id = it.provider_league_id
        AND ip.season = it.season
  );