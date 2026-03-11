CREATE TABLE IF NOT EXISTS ops.sports_import_plan
(
    id BIGSERIAL PRIMARY KEY,

    sport_code TEXT NOT NULL UNIQUE,              -- football, hockey, tennis, mma...
    sport_name TEXT NOT NULL,                     -- Football, Hockey...
    enabled BOOLEAN NOT NULL DEFAULT true,

    priority INT NOT NULL DEFAULT 100,            -- nižší číslo = vyšší priorita
    mode TEXT NOT NULL DEFAULT 'bootstrap',       -- bootstrap / daily / paused

    provider TEXT NOT NULL DEFAULT 'api-sports',  -- hlavní provider
    daily_request_budget INT NOT NULL DEFAULT 7500,
    max_parallel_jobs INT NOT NULL DEFAULT 1,

    history_days_back INT NOT NULL DEFAULT 3650,  -- cca 10 let
    fixtures_days_forward INT NOT NULL DEFAULT 14,
    odds_days_forward INT NOT NULL DEFAULT 3,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sports_import_plan_enabled
    ON ops.sports_import_plan(enabled);

CREATE INDEX IF NOT EXISTS idx_sports_import_plan_priority
    ON ops.sports_import_plan(priority);