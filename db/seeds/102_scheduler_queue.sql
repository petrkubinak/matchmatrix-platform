CREATE TABLE IF NOT EXISTS ops.scheduler_queue
(
    id BIGSERIAL PRIMARY KEY,

    queue_day DATE NOT NULL DEFAULT CURRENT_DATE,
    sport_code TEXT NOT NULL,

    target_id BIGINT NOT NULL,
    canonical_league_id BIGINT NOT NULL,

    provider TEXT NOT NULL,
    provider_league_id TEXT NOT NULL,
    season TEXT NOT NULL DEFAULT '',

    tier INT NOT NULL,
    run_group TEXT,
    max_requests_per_run INT NOT NULL DEFAULT 1,

    status TEXT NOT NULL DEFAULT 'pending',   -- pending / running / done / error / skipped
    selected_by TEXT NOT NULL DEFAULT 'run_multisport_scheduler_v3',

    selected_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,

    message TEXT
);

CREATE INDEX IF NOT EXISTS idx_scheduler_queue_day_status
    ON ops.scheduler_queue(queue_day, status);

CREATE INDEX IF NOT EXISTS idx_scheduler_queue_sport_status
    ON ops.scheduler_queue(sport_code, status);

CREATE UNIQUE INDEX IF NOT EXISTS ux_scheduler_queue_day_target
    ON ops.scheduler_queue(queue_day, target_id);