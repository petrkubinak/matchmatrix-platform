CREATE TABLE IF NOT EXISTS ops.api_budget_status
(
    id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL,
    request_day DATE NOT NULL DEFAULT CURRENT_DATE,

    requests_used INT NOT NULL DEFAULT 0,
    requests_limit INT NOT NULL DEFAULT 7500,

    requests_remaining INT GENERATED ALWAYS AS
    (requests_limit - requests_used) STORED,

    last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_api_budget_sport_day
ON ops.api_budget_status(sport_code, request_day);

INSERT INTO ops.api_budget_status (sport_code, requests_limit)
SELECT sport_code, daily_request_budget
FROM ops.sports_import_plan
WHERE enabled = true
ON CONFLICT DO NOTHING;