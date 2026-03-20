-- ============================================================
-- MatchMatrix
-- 038_alter_stg_provider_player_stats_for_match_merge.sql
--
-- Účel:
-- rozšíření staging.stg_provider_player_stats pro merge
-- do public.player_match_statistics
-- ============================================================

ALTER TABLE staging.stg_provider_player_stats
    ADD COLUMN IF NOT EXISTS team_external_id text,
    ADD COLUMN IF NOT EXISTS external_league_id text,
    ADD COLUMN IF NOT EXISTS season text,
    ADD COLUMN IF NOT EXISTS source_endpoint text,
    ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS ix_stg_provider_player_stats_match_player
    ON staging.stg_provider_player_stats (provider, external_fixture_id, player_external_id);

CREATE INDEX IF NOT EXISTS ix_stg_provider_player_stats_team
    ON staging.stg_provider_player_stats (provider, team_external_id);

CREATE INDEX IF NOT EXISTS ix_stg_provider_player_stats_stat_name
    ON staging.stg_provider_player_stats (stat_name);

COMMENT ON COLUMN staging.stg_provider_player_stats.team_external_id
    IS 'Provider team ID for the player stat row';

COMMENT ON COLUMN staging.stg_provider_player_stats.external_league_id
    IS 'Provider league ID if available';

COMMENT ON COLUMN staging.stg_provider_player_stats.season
    IS 'Season code if available';

COMMENT ON COLUMN staging.stg_provider_player_stats.source_endpoint
    IS 'Source endpoint used for this stat row';

COMMENT ON COLUMN staging.stg_provider_player_stats.updated_at
    IS 'Last update timestamp of staging row';