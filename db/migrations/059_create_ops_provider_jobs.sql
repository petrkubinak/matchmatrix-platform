CREATE TABLE IF NOT EXISTS ops.provider_jobs (
    id BIGSERIAL PRIMARY KEY,
    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    job_code TEXT NOT NULL,
    endpoint_code TEXT NOT NULL,
    ingest_mode TEXT NOT NULL, -- slow / medium / fast
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    priority INT NOT NULL DEFAULT 100,
    batch_size INT,
    max_requests_per_run INT,
    retry_limit INT NOT NULL DEFAULT 3,
    cooldown_seconds INT NOT NULL DEFAULT 0,
    days_back INT,
    days_forward INT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_provider_jobs_ingest_mode
        CHECK (ingest_mode IN ('slow', 'medium', 'fast'))
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_provider_jobs_unique
    ON ops.provider_jobs(provider, sport_code, job_code);

CREATE INDEX IF NOT EXISTS idx_provider_jobs_provider_mode
    ON ops.provider_jobs(provider, sport_code, ingest_mode, enabled);

CREATE INDEX IF NOT EXISTS idx_provider_jobs_endpoint
    ON ops.provider_jobs(provider, sport_code, endpoint_code);