BEGIN;

-- =========================================================
-- MATCHMATRIX
-- Doplneni novych player entit do ops.ingest_planner
-- =========================================================

-- 1) player_profiles
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
    next_run
)
SELECT
    provider,
    sport_code,
    'player_profiles' AS entity,
    provider_league_id,
    season,
    run_group,
    priority,
    'pending' AS status,
    0 AS attempts,
    NOW() AS next_run
FROM ops.ingest_planner p
WHERE p.sport_code = 'football'
  AND p.entity = 'players'
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner x
      WHERE x.provider = p.provider
        AND x.sport_code = p.sport_code
        AND x.entity = 'player_profiles'
        AND COALESCE(x.provider_league_id, '') = COALESCE(p.provider_league_id, '')
        AND COALESCE(x.season, '') = COALESCE(p.season, '')
        AND COALESCE(x.run_group, '') = COALESCE(p.run_group, '')
  );

-- 2) player_season_stats
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
    next_run
)
SELECT
    provider,
    sport_code,
    'player_season_stats' AS entity,
    provider_league_id,
    season,
    run_group,
    priority,
    'pending' AS status,
    0 AS attempts,
    NOW() AS next_run
FROM ops.ingest_planner p
WHERE p.sport_code = 'football'
  AND p.entity = 'players'
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner x
      WHERE x.provider = p.provider
        AND x.sport_code = p.sport_code
        AND x.entity = 'player_season_stats'
        AND COALESCE(x.provider_league_id, '') = COALESCE(p.provider_league_id, '')
        AND COALESCE(x.season, '') = COALESCE(p.season, '')
        AND COALESCE(x.run_group, '') = COALESCE(p.run_group, '')
  );

-- 3) player_stats
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
    next_run
)
SELECT
    provider,
    sport_code,
    'player_stats' AS entity,
    provider_league_id,
    season,
    run_group,
    priority,
    'pending' AS status,
    0 AS attempts,
    NOW() AS next_run
FROM ops.ingest_planner p
WHERE p.sport_code = 'football'
  AND p.entity = 'players'
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner x
      WHERE x.provider = p.provider
        AND x.sport_code = p.sport_code
        AND x.entity = 'player_stats'
        AND COALESCE(x.provider_league_id, '') = COALESCE(p.provider_league_id, '')
        AND COALESCE(x.season, '') = COALESCE(p.season, '')
        AND COALESCE(x.run_group, '') = COALESCE(p.run_group, '')
  );

COMMIT;