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
    it.sport_code,
    'players' AS entity,
    it.provider_league_id,
    it.season,
    it.sport_code || '_PEOPLE_AUTO_2024' AS run_group,
    300 AS priority,
    'pending' AS status,
    0 AS attempts,
    NULL AS next_run,
    now() AS created_at,
    now() AS updated_at
FROM ops.ingest_targets it
WHERE it.enabled = true
  AND it.season = '2024'
  AND it.provider_league_id IS NOT NULL
  AND it.sport_code IN ('FB','HK','BK','VB','HB','BSB','RGB','CK','AFB')
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner ip
      WHERE ip.provider = it.provider
        AND ip.sport_code = it.sport_code
        AND ip.entity = 'players'
        AND ip.provider_league_id = it.provider_league_id
        AND ip.season = it.season
  );