-- 035_seed_bk_fixtures_planner_from_targets.sql
-- Cíl:
-- vytvořit chybějící planner joby pro BK fixtures z ops.ingest_targets

INSERT INTO ops.ingest_planner
(
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    status,
    attempts,
    priority,
    run_group,
    created_at,
    updated_at
)
SELECT
    t.provider,
    t.sport_code,
    'fixtures' AS entity,
    t.provider_league_id,
    t.season,
    'pending' AS status,
    0 AS attempts,
    2030 AS priority,
    t.run_group,
    now(),
    now()
FROM ops.ingest_targets t
WHERE t.provider = 'api_sport'
  AND t.sport_code = 'BK'
  AND t.run_group = 'BK_TOP'
  AND COALESCE(t.enabled, true) = true
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

-- kontrola
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
ORDER BY priority, id;