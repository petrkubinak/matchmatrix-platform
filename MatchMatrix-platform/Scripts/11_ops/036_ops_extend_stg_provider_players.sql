/*
MATCHMATRIX
Migration: 036_ops_extend_stg_provider_players
Purpose : Rozšíření unified staging tabulky hráčů
Author  : MatchMatrix
*/

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

COMMENT ON COLUMN staging.stg_provider_players.first_name IS 'Player first name';
COMMENT ON COLUMN staging.stg_provider_players.last_name IS 'Player last name';
COMMENT ON COLUMN staging.stg_provider_players.short_name IS 'Display short name';
COMMENT ON COLUMN staging.stg_provider_players.position_code IS 'Position code (FW, MF, DF, GK)';
COMMENT ON COLUMN staging.stg_provider_players.height_cm IS 'Height in cm';
COMMENT ON COLUMN staging.stg_provider_players.weight_kg IS 'Weight in kg';
COMMENT ON COLUMN staging.stg_provider_players.preferred_foot IS 'Preferred foot';
COMMENT ON COLUMN staging.stg_provider_players.external_league_id IS 'Provider league ID';
COMMENT ON COLUMN staging.stg_provider_players.team_name IS 'Team name from provider';
COMMENT ON COLUMN staging.stg_provider_players.league_name IS 'League name from provider';
COMMENT ON COLUMN staging.stg_provider_players.source_endpoint IS 'API endpoint used to obtain player';