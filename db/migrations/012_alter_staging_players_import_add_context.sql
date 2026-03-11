BEGIN;

ALTER TABLE staging.players_import
    ADD COLUMN IF NOT EXISTS run_id bigint,
    ADD COLUMN IF NOT EXISTS provider_league_id text,
    ADD COLUMN IF NOT EXISTS provider_team_id text,
    ADD COLUMN IF NOT EXISTS season text,
    ADD COLUMN IF NOT EXISTS league_name text,
    ADD COLUMN IF NOT EXISTS team_name text,
    ADD COLUMN IF NOT EXISTS source_endpoint text,
    ADD COLUMN IF NOT EXISTS imported_at timestamptz NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS ix_players_import_provider_player
    ON staging.players_import (provider_code, provider_player_id);

CREATE INDEX IF NOT EXISTS ix_players_import_league_season
    ON staging.players_import (provider_league_id, season);

CREATE INDEX IF NOT EXISTS ix_players_import_team_season
    ON staging.players_import (provider_team_id, season);

COMMIT;