-- =====================================================
-- MatchMatrix
-- Table: staging.player_provider_map_import
-- File: 007_create_table_staging_player_provider_map_import.sql
-- =====================================================

CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.player_provider_map_import
(
    provider_code         TEXT        NOT NULL,
    provider_player_id    TEXT        NOT NULL,
    player_name           TEXT        NOT NULL,
    birth_date            DATE,
    nationality           TEXT,
    imported_at           TIMESTAMPTZ DEFAULT now(),
    raw_json              JSONB
);

CREATE INDEX IF NOT EXISTS ix_player_provider_map_import_provider
    ON staging.player_provider_map_import (provider_code, provider_player_id);