CREATE TABLE IF NOT EXISTS ops.api_request_log (
    id BIGSERIAL PRIMARY KEY,
    provider TEXT NOT NULL,
    account_name TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    job_code TEXT,
    endpoint_code TEXT,
    request_date DATE NOT NULL DEFAULT CURRENT_DATE,
    request_count INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_api_request_log_provider_sport_date
    ON ops.api_request_log(provider, account_name, sport_code, request_date);