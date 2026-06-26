CREATE TABLE ops.ingest_planner (
    
    id BIGSERIAL PRIMARY KEY,

    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    entity TEXT NOT NULL,

    provider_league_id TEXT,
    season TEXT,

    run_group TEXT,

    priority INT DEFAULT 5,

    status TEXT DEFAULT 'pending',

    attempts INT DEFAULT 0,

    last_attempt TIMESTAMPTZ,
    next_run TIMESTAMPTZ,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()

);