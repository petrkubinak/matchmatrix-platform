-- ============================================================
-- 880_seed_people_media_entities_v1.sql
-- MatchMatrix - People + Media entity seed
--
-- OPRAVA:
-- - ingest_mode = 'daily' místo nepovoleného 'manual'
-- - scope_type = 'league_season' pro bezpečný průchod constraintem
--
-- Kam uložit:
-- C:\MatchMatrix-platform\db\audit\880_seed_people_media_entities_v1.sql
--
-- Spustit v DBeaveru nad DB matchmatrix.
-- ============================================================

BEGIN;

INSERT INTO ops.ingest_entity_plan
(
    provider,
    sport_code,
    entity,
    enabled,
    priority,
    scope_type,
    requires_league,
    requires_season,
    default_run_group,
    ingest_mode,
    source_endpoint,
    target_table,
    worker_script,
    notes,
    created_at,
    updated_at
)
VALUES
-- PEOPLE - FB
('api_football', 'FB', 'players', true, 300, 'league_season', true, true, 'FB_PEOPLE', 'daily', 'players', 'staging.stg_provider_players', 'workers/run_players_fetch_only_v1.py', 'People layer - players prepared for automation.', NOW(), NOW()),
('api_football', 'FB', 'player_profiles', true, 310, 'league_season', true, true, 'FB_PEOPLE', 'daily', 'player_profiles', 'staging.stg_provider_player_profiles', NULL, 'People layer - player profiles planned.', NOW(), NOW()),
('api_football', 'FB', 'player_season_stats', true, 320, 'league_season', true, true, 'FB_PEOPLE', 'daily', 'player_season_stats', 'staging.stg_provider_player_season_stats', 'workers/run_players_parse_only_v1.py', 'People layer - player season stats prepared.', NOW(), NOW()),
('api_football', 'FB', 'player_stats', true, 330, 'league_season', true, true, 'FB_PEOPLE', 'daily', 'player_stats', 'staging.stg_provider_player_stats', NULL, 'People layer - player stats planned.', NOW(), NOW()),
('api_football', 'FB', 'coaches', true, 340, 'league_season', true, true, 'FB_PEOPLE', 'daily', 'coaches', 'staging.stg_provider_coaches', NULL, 'People layer - coaches planned.', NOW(), NOW()),

-- PEOPLE - MULTISPORT PLACEHOLDERS
('api_hockey', 'HK', 'players', true, 400, 'league_season', true, true, 'HK_PEOPLE', 'daily', 'players', 'staging.stg_provider_players', NULL, 'People layer placeholder.', NOW(), NOW()),
('api_hockey', 'HK', 'coaches', true, 410, 'league_season', true, true, 'HK_PEOPLE', 'daily', 'coaches', 'staging.stg_provider_coaches', NULL, 'People layer placeholder.', NOW(), NOW()),

('api_sport', 'BK', 'players', true, 400, 'league_season', true, true, 'BK_PEOPLE', 'daily', 'players', 'staging.stg_provider_players', NULL, 'People layer placeholder.', NOW(), NOW()),
('api_sport', 'BK', 'coaches', true, 410, 'league_season', true, true, 'BK_PEOPLE', 'daily', 'coaches', 'staging.stg_provider_coaches', NULL, 'People layer placeholder.', NOW(), NOW()),

('api_volleyball', 'VB', 'players', true, 400, 'league_season', true, true, 'VB_PEOPLE', 'daily', 'players', 'staging.stg_provider_players', NULL, 'People layer placeholder.', NOW(), NOW()),
('api_volleyball', 'VB', 'coaches', true, 410, 'league_season', true, true, 'VB_PEOPLE', 'daily', 'coaches', 'staging.stg_provider_coaches', NULL, 'People layer placeholder.', NOW(), NOW()),

('api_handball', 'HB', 'players', true, 400, 'league_season', true, true, 'HB_PEOPLE', 'daily', 'players', 'staging.stg_provider_players', NULL, 'People layer placeholder.', NOW(), NOW()),
('api_handball', 'HB', 'coaches', true, 410, 'league_season', true, true, 'HB_PEOPLE', 'daily', 'coaches', 'staging.stg_provider_coaches', NULL, 'People layer placeholder.', NOW(), NOW()),

('api_baseball', 'BSB', 'players', true, 400, 'league_season', true, true, 'BSB_PEOPLE', 'daily', 'players', 'staging.stg_provider_players', NULL, 'People layer placeholder.', NOW(), NOW()),
('api_baseball', 'BSB', 'coaches', true, 410, 'league_season', true, true, 'BSB_PEOPLE', 'daily', 'coaches', 'staging.stg_provider_coaches', NULL, 'People layer placeholder.', NOW(), NOW()),

('api_rugby', 'RGB', 'players', true, 400, 'league_season', true, true, 'RGB_PEOPLE', 'daily', 'players', 'staging.stg_provider_players', NULL, 'People layer placeholder.', NOW(), NOW()),
('api_rugby', 'RGB', 'coaches', true, 410, 'league_season', true, true, 'RGB_PEOPLE', 'daily', 'coaches', 'staging.stg_provider_coaches', NULL, 'People layer placeholder.', NOW(), NOW()),

('api_cricket', 'CK', 'players', true, 400, 'league_season', true, true, 'CK_PEOPLE', 'daily', 'players', 'staging.stg_provider_players', NULL, 'People layer placeholder.', NOW(), NOW()),
('api_cricket', 'CK', 'coaches', true, 410, 'league_season', true, true, 'CK_PEOPLE', 'daily', 'coaches', 'staging.stg_provider_coaches', NULL, 'People layer placeholder.', NOW(), NOW()),

('api_american_football', 'AFB', 'players', true, 400, 'league_season', true, true, 'AFB_PEOPLE', 'daily', 'players', 'staging.stg_provider_players', NULL, 'People layer placeholder.', NOW(), NOW()),
('api_american_football', 'AFB', 'coaches', true, 410, 'league_season', true, true, 'AFB_PEOPLE', 'daily', 'coaches', 'staging.stg_provider_coaches', NULL, 'People layer placeholder.', NOW(), NOW()),

-- MEDIA / HIGHLIGHTS
('api_football', 'FB', 'highlights', true, 700, 'league_season', true, true, 'FB_MEDIA', 'daily', 'highlights', 'staging.stg_provider_events', NULL, 'Media layer placeholder.', NOW(), NOW()),
('api_football', 'FB', 'articles', true, 710, 'league_season', true, true, 'FB_MEDIA', 'daily', 'articles', 'staging.stg_provider_events', NULL, 'Media layer placeholder.', NOW(), NOW()),
('api_football', 'FB', 'comments', true, 720, 'league_season', true, true, 'FB_MEDIA', 'daily', 'comments', 'staging.stg_provider_events', NULL, 'Media layer placeholder.', NOW(), NOW()),
('api_football', 'FB', 'videos', true, 730, 'league_season', true, true, 'FB_MEDIA', 'daily', 'videos', 'staging.stg_provider_events', NULL, 'Media layer placeholder.', NOW(), NOW()),

('api_hockey', 'HK', 'highlights', true, 700, 'league_season', true, true, 'HK_MEDIA', 'daily', 'highlights', 'staging.stg_provider_events', NULL, 'Media layer placeholder.', NOW(), NOW()),
('api_sport', 'BK', 'highlights', true, 700, 'league_season', true, true, 'BK_MEDIA', 'daily', 'highlights', 'staging.stg_provider_events', NULL, 'Media layer placeholder.', NOW(), NOW()),
('api_volleyball', 'VB', 'highlights', true, 700, 'league_season', true, true, 'VB_MEDIA', 'daily', 'highlights', 'staging.stg_provider_events', NULL, 'Media layer placeholder.', NOW(), NOW()),
('api_handball', 'HB', 'highlights', true, 700, 'league_season', true, true, 'HB_MEDIA', 'daily', 'highlights', 'staging.stg_provider_events', NULL, 'Media layer placeholder.', NOW(), NOW()),
('api_baseball', 'BSB', 'highlights', true, 700, 'league_season', true, true, 'BSB_MEDIA', 'daily', 'highlights', 'staging.stg_provider_events', NULL, 'Media layer placeholder.', NOW(), NOW()),
('api_rugby', 'RGB', 'highlights', true, 700, 'league_season', true, true, 'RGB_MEDIA', 'daily', 'highlights', 'staging.stg_provider_events', NULL, 'Media layer placeholder.', NOW(), NOW()),
('api_cricket', 'CK', 'highlights', true, 700, 'league_season', true, true, 'CK_MEDIA', 'daily', 'highlights', 'staging.stg_provider_events', NULL, 'Media layer placeholder.', NOW(), NOW()),
('api_american_football', 'AFB', 'highlights', true, 700, 'league_season', true, true, 'AFB_MEDIA', 'daily', 'highlights', 'staging.stg_provider_events', NULL, 'Media layer placeholder.', NOW(), NOW())

ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    enabled = EXCLUDED.enabled,
    priority = EXCLUDED.priority,
    scope_type = EXCLUDED.scope_type,
    requires_league = EXCLUDED.requires_league,
    requires_season = EXCLUDED.requires_season,
    default_run_group = EXCLUDED.default_run_group,
    ingest_mode = EXCLUDED.ingest_mode,
    source_endpoint = EXCLUDED.source_endpoint,
    target_table = EXCLUDED.target_table,
    worker_script = EXCLUDED.worker_script,
    notes = EXCLUDED.notes,
    updated_at = NOW();

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    enabled,
    scope_type,
    ingest_mode,
    default_run_group,
    target_table,
    worker_script
FROM ops.ingest_entity_plan
WHERE entity IN (
    'players',
    'player_profiles',
    'player_season_stats',
    'player_stats',
    'coaches',
    'highlights',
    'articles',
    'comments',
    'videos'
)
ORDER BY sport_code, provider, priority, entity;