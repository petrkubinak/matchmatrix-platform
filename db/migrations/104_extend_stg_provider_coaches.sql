ROLLBACK;
BEGIN;

-- =========================================================
-- 104_extend_stg_provider_coaches.sql
-- Rozšíření EXISTUJÍCÍ staging.stg_provider_coaches
-- pro multisport ingest trenérů
-- =========================================================

ALTER TABLE staging.stg_provider_coaches
    ADD COLUMN IF NOT EXISTS short_name TEXT,
    ADD COLUMN IF NOT EXISTS birth_date DATE,
    ADD COLUMN IF NOT EXISTS birth_place TEXT,
    ADD COLUMN IF NOT EXISTS birth_country TEXT,
    ADD COLUMN IF NOT EXISTS nationality_code TEXT,
    ADD COLUMN IF NOT EXISTS photo_url TEXT,
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN,
    ADD COLUMN IF NOT EXISTS league_name TEXT,
    ADD COLUMN IF NOT EXISTS source_endpoint TEXT,
    ADD COLUMN IF NOT EXISTS raw_payload_id BIGINT,
    ADD COLUMN IF NOT EXISTS fetched_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

CREATE INDEX IF NOT EXISTS idx_stg_provider_coaches_team_ext
    ON staging.stg_provider_coaches (team_external_id);

CREATE INDEX IF NOT EXISTS idx_stg_provider_coaches_league_ext
    ON staging.stg_provider_coaches (league_external_id);

CREATE INDEX IF NOT EXISTS idx_stg_provider_coaches_sport_provider
    ON staging.stg_provider_coaches (sport_code, provider);

COMMIT;