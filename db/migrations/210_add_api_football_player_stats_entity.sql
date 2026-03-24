-- =========================================================
-- MatchMatrix
-- 210_add_api_football_player_stats_entity.sql
--
-- Účel:
-- přidat player_stats do ingest_entity_plan (SPRÁVNÁ STRUKTURA)
-- =========================================================

BEGIN;

INSERT INTO ops.ingest_entity_plan (
    provider,
    sport_code,
    entity,
    enabled,
    priority,
    scope_type,
    requires_league,
    requires_season,
    ingest_mode,
    source_endpoint,
    target_table,
    worker_script,
    notes,
    created_at,
    updated_at
)
SELECT
    'api_football',
    'FB',
    'player_stats',
    true,
    65,                                 -- po season stats
    'league_season',
    true,
    true,
    'daily',
    'fixtures/players',                 -- API endpoint
    'staging.stg_provider_player_stats',
    'pull_api_football_player_stats.ps1', -- budoucí worker
    'Football match player stats',
    now(),
    now()
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.ingest_entity_plan x
    WHERE x.provider = 'api_football'
      AND x.sport_code = 'FB'
      AND x.entity = 'player_stats'
);

COMMIT;