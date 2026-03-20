-- ============================================================================
-- 057_add_unique_index_stg_provider_player_season_stats.sql
-- Cíl:
--   Přidat unikátní business index do staging.stg_provider_player_season_stats
--   pro idempotentní parse endpointu "players"
-- ============================================================================

CREATE UNIQUE INDEX IF NOT EXISTS ux_stg_player_season_stats_business
ON staging.stg_provider_player_season_stats
(
    provider,
    sport_code,
    COALESCE(external_league_id, ''),
    COALESCE(season, ''),
    player_external_id,
    COALESCE(team_external_id, ''),
    stat_name,
    COALESCE(source_endpoint, '')
);