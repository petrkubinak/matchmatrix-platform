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
    t.provider,
    t.sport_code,
    'fixtures' AS entity,
    t.provider_league_id,
    t.season,
    t.run_group,
    COALESCE(t.tier, 100) AS priority,
    'pending' AS status,
    0 AS attempts,
    NOW() AS next_run,
    NOW() AS created_at,
    NOW() AS updated_at
FROM ops.ingest_targets t
WHERE t.provider = 'api_football'
  AND t.sport_code = 'FB'
  AND t.enabled = true
  AND t.run_group = 'EU_top,EU_exact_v1'
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner p
      WHERE p.provider = t.provider
        AND p.sport_code = t.sport_code
        AND p.entity = 'fixtures'
        AND p.provider_league_id = t.provider_league_id
        AND COALESCE(p.season, '') = COALESCE(t.season, '')
        AND COALESCE(p.run_group, '') = COALESCE(t.run_group, '')
  );