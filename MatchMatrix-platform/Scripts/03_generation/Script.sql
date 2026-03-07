-- =====================================================
-- MatchMatrix
-- Table: staging.players_import
-- File: 006_create_table_staging_players_import.sql
-- =====================================================

CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.players_import
(
    provider_code         TEXT        NOT NULL,
    provider_player_id    TEXT        NOT NULL,
    player_name           TEXT        NOT NULL,
    first_name            TEXT,
    last_name             TEXT,
    birth_date            DATE,
    nationality           TEXT,
    height_cm             INTEGER,
    weight_kg             INTEGER,
    preferred_foot        TEXT,
    position_code         TEXT,
    team_provider_id      TEXT,
    team_name             TEXT,
    season_code           TEXT,
    is_active             BOOLEAN     DEFAULT true,
    raw_json              JSONB,
    imported_at           TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_players_import_provider_player_id
    ON staging.players_import (provider_code, provider_player_id);

CREATE INDEX IF NOT EXISTS ix_players_import_player_name
    ON staging.players_import (player_name);