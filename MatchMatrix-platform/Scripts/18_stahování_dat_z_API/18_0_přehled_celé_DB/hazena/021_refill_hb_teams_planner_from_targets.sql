INSERT INTO ops.ingest_planner
(
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
)
SELECT
    t.provider,
    t.sport_code,
    'teams' AS entity,
    t.provider_league_id,
    t.season,
    t.run_group,
    COALESCE(t.tier, 100) AS priority,
    'pending' AS status,
    0 AS attempts,
    NULL AS last_attempt,
    NOW() AS next_run,
    NOW() AS created_at,
    NOW() AS updated_at
FROM ops.ingest_targets t
WHERE t.sport_code = 'HB'
  AND t.provider = 'api_handball'
  AND t.run_group = 'HB_CORE'
  AND t.enabled = true
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner p
      WHERE p.provider = t.provider
        AND p.sport_code = t.sport_code
        AND p.entity = 'teams'
        AND p.provider_league_id = t.provider_league_id
        AND COALESCE(p.season, '') = COALESCE(t.season, '')
        AND COALESCE(p.run_group, '') = COALESCE(t.run_group, '')
        AND p.status IN ('pending', 'claimed', 'running', 'done')
  );