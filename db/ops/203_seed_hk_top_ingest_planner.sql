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
    r.entity,
    t.provider_league_id,
    NULLIF(t.season, '') AS season,
    t.run_group,
    r.priority,
    'pending' AS status,
    0 AS attempts,
    NOW() AS next_run,
    NOW() AS created_at,
    NOW() AS updated_at
FROM ops.ingest_targets t
JOIN ops.v_ops_hk_top_full_runnable_jobs r
  ON r.provider = t.provider
 AND r.sport_code = t.sport_code
 AND r.run_group = t.run_group
WHERE t.provider = 'api_hockey'
  AND t.sport_code = 'HK'
  AND t.run_group = 'HK_TOP'
  AND t.enabled = true
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner p
      WHERE p.provider = t.provider
        AND p.sport_code = t.sport_code
        AND p.entity = r.entity
        AND COALESCE(p.provider_league_id, '') = COALESCE(t.provider_league_id, '')
        AND COALESCE(p.season, '') = COALESCE(t.season, '')
        AND COALESCE(p.run_group, '') = COALESCE(t.run_group, '')
  );