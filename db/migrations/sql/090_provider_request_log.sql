CREATE TABLE IF NOT EXISTS provider_request_log
(
    id BIGSERIAL PRIMARY KEY,

    provider_id INT NOT NULL,
    sport_id INT NOT NULL,

    endpoint_name TEXT NOT NULL,

    request_ts TIMESTAMP NOT NULL DEFAULT now(),
    request_day DATE NOT NULL DEFAULT CURRENT_DATE,

    status_code INT,
    success_flag BOOLEAN,

    payload_items INT,
    payload_bytes BIGINT,

    notes TEXT
);

CREATE INDEX idx_provider_request_day
ON provider_request_log(request_day);

CREATE INDEX idx_provider_request_sport
ON provider_request_log(sport_id);