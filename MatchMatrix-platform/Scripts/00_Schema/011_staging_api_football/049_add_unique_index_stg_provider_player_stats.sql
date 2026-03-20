-- ============================================================================
-- MatchMatrix
-- Soubor: 049_add_unique_index_stg_provider_player_stats.sql
-- Cíl:
--   Přidat unikátní index do staging.stg_provider_player_stats,
--   aby ingest /fixtures/players byl idempotentní a neukládal duplicity.
--
-- Proč:
--   Tabulka má nyní pouze PK(id) a běžné indexy, ale ne unikátní klíč
--   na business identitu jednoho stat řádku.
--
-- Poznámka:
--   COALESCE je použito kvůli nullable sloupcům.
-- ============================================================================

CREATE UNIQUE INDEX IF NOT EXISTS ux_stg_provider_player_stats_business
ON staging.stg_provider_player_stats
(
    provider,
    sport_code,
    external_fixture_id,
    player_external_id,
    stat_name,
    COALESCE(team_external_id, ''),
    COALESCE(external_league_id, ''),
    COALESCE(season, ''),
    COALESCE(source_endpoint, '')
);