-- MatchMatrix - Players DB completion (staging)
-- Ulozit do: C:\MatchMatrix-platform\db\migrations\047_players_staging_completion.sql

BEGIN;

CREATE TABLE IF NOT EXISTS staging.stg_provider_player_season_stats (
    id bigserial PRIMARY KEY,
    provider text NOT NULL,
    sport_code text NOT NULL DEFAULT 'football',
    provider_player_id text NOT NULL,
    player_name text,
    external_team_id text,
    external_league_id text,
    season integer,
    stat_name text NOT NULL,
    stat_value numeric(18,4),
    raw_payload_id bigint,
    raw_json jsonb,
    source_endpoint text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS staging.stg_provider_player_stats (
    id bigserial PRIMARY KEY,
    provider text NOT NULL,
    sport_code text NOT NULL DEFAULT 'football',
    external_fixture_id text NOT NULL,
    external_team_id text,
    external_player_id text NOT NULL,
    minute integer,
    stat_name text NOT NULL,
    stat_value numeric(18,4),
    raw_payload_id bigint,
    raw_json jsonb,
    source_endpoint text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE staging.stg_provider_players
    ADD COLUMN IF NOT EXISTS external_league_id text,
    ADD COLUMN IF NOT EXISTS source_endpoint text,
    ADD COLUMN IF NOT EXISTS raw_json jsonb;

CREATE INDEX IF NOT EXISTS ix_stg_provider_player_season_stats_lookup
    ON staging.stg_provider_player_season_stats (provider, provider_player_id, external_team_id, external_league_id, season);

CREATE INDEX IF NOT EXISTS ix_stg_provider_player_stats_lookup
    ON staging.stg_provider_player_stats (provider, external_fixture_id, external_player_id);

CREATE INDEX IF NOT EXISTS ix_stg_provider_player_stats_team
    ON staging.stg_provider_player_stats (external_team_id);

COMMIT;
