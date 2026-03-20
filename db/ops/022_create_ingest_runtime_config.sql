CREATE TABLE IF NOT EXISTS ops.ingest_runtime_config (
    id BIGSERIAL PRIMARY KEY,
    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    plan_code TEXT NOT NULL,
    season_min TEXT NULL,
    season_max TEXT NULL,
    maintenance_season TEXT NULL,
    max_daily_requests INTEGER NULL,
    notes TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_ingest_runtime_config UNIQUE (provider, sport_code, plan_code)
);