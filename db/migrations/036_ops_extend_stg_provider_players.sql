-- MatchMatrix
-- Soubor ulož do: C:\MatchMatrix-platform\db\migrations\036_ops_extend_stg_provider_players.sql
-- Účel: rozšíření unified staging tabulky pro players pipeline

BEGIN;

ALTER TABLE staging.stg_provider_players
    ADD COLUMN IF NOT EXISTS first_name text,
    ADD COLUMN IF NOT EXISTS last_name text,
    ADD COLUMN IF NOT EXISTS short_name text,
    ADD COLUMN IF NOT EXISTS position_code text,
    ADD COLUMN IF NOT EXISTS height_cm integer,
    ADD COLUMN IF NOT EXISTS weight_kg integer,
    ADD COLUMN IF NOT EXISTS preferred_foot text,
    ADD COLUMN IF NOT EXISTS external_league_id text,
    ADD COLUMN IF NOT EXISTS team_name text,
    ADD COLUMN IF NOT EXISTS league_name text,
    ADD COLUMN IF NOT EXISTS source_endpoint text;

COMMENT ON COLUMN staging.stg_provider_players.first_name IS 'Provider first name from players source ingest';
COMMENT ON COLUMN staging.stg_provider_players.last_name IS 'Provider last name from players source ingest';
COMMENT ON COLUMN staging.stg_provider_players.short_name IS 'Optional short/display name for canonical merge';
COMMENT ON COLUMN staging.stg_provider_players.position_code IS 'Provider position code (e.g. G, D, F, GK, DF, MF, FW)';
COMMENT ON COLUMN staging.stg_provider_players.height_cm IS 'Player height in centimeters';
COMMENT ON COLUMN staging.stg_provider_players.weight_kg IS 'Player weight in kilograms';
COMMENT ON COLUMN staging.stg_provider_players.preferred_foot IS 'Preferred foot / handedness where provider exposes it';
COMMENT ON COLUMN staging.stg_provider_players.external_league_id IS 'Provider league id connected to player ingest';
COMMENT ON COLUMN staging.stg_provider_players.team_name IS 'Provider team name captured during ingest';
COMMENT ON COLUMN staging.stg_provider_players.league_name IS 'Provider league name captured during ingest';
COMMENT ON COLUMN staging.stg_provider_players.source_endpoint IS 'Provider endpoint name/path used for ingest';

CREATE INDEX IF NOT EXISTS ix_stg_provider_players_team_season
    ON staging.stg_provider_players (provider, external_team_id, season);

CREATE INDEX IF NOT EXISTS ix_stg_provider_players_league_season
    ON staging.stg_provider_players (provider, external_league_id, season);

CREATE INDEX IF NOT EXISTS ix_stg_provider_players_name
    ON staging.stg_provider_players (player_name);

COMMIT;
