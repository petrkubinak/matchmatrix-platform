-- =====================================================
-- STAGING ODDS
-- =====================================================

CREATE TABLE IF NOT EXISTS staging.stg_provider_odds
(
    id BIGSERIAL PRIMARY KEY,

    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,

    external_fixture_id TEXT NOT NULL,
    bookmaker_name TEXT NOT NULL,

    market_type TEXT NOT NULL,       -- 1x2, moneyline, over_under...
    outcome_name TEXT NOT NULL,      -- home / draw / away / over / under

    odds_value NUMERIC(10,4),
    odds_timestamp TIMESTAMPTZ,

    raw_payload_id BIGINT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_stg_provider_odds_fixture
    ON ops.stg_provider_odds(provider, external_fixture_id);



-- =====================================================
-- STAGING MATCH EVENTS
-- =====================================================

CREATE TABLE IF NOT EXISTS staging.stg_provider_events
(
    id BIGSERIAL PRIMARY KEY,

    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,

    external_fixture_id TEXT NOT NULL,

    minute INT,
    event_type TEXT,                 -- goal, card, penalty, substitution...
    team_external_id TEXT,
    player_external_id TEXT,

    event_detail TEXT,

    raw_payload_id BIGINT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_stg_provider_events_fixture
    ON ops.stg_provider_events(provider, external_fixture_id);



-- =====================================================
-- STAGING TEAM MATCH STATS
-- =====================================================

CREATE TABLE IF NOT EXISTS staging.stg_provider_team_stats
(
    id BIGSERIAL PRIMARY KEY,

    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,

    external_fixture_id TEXT NOT NULL,
    team_external_id TEXT NOT NULL,

    stat_name TEXT NOT NULL,
    stat_value TEXT,

    raw_payload_id BIGINT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_stg_provider_team_stats_fixture
    ON ops.stg_provider_team_stats(provider, external_fixture_id);



-- =====================================================
-- STAGING PLAYER MATCH STATS
-- =====================================================

CREATE TABLE IF NOT EXISTS staging.stg_provider_player_stats
(
    id BIGSERIAL PRIMARY KEY,

    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,

    external_fixture_id TEXT NOT NULL,
    player_external_id TEXT NOT NULL,

    stat_name TEXT NOT NULL,
    stat_value TEXT,

    raw_payload_id BIGINT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_stg_provider_player_stats_fixture
    ON ops.stg_provider_player_stats(provider, external_fixture_id);