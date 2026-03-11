CREATE TABLE IF NOT EXISTS staging.stg_api_payloads
(
    id BIGSERIAL PRIMARY KEY,
    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    entity_type TEXT NOT NULL,              -- leagues, teams, players, fixtures, odds...
    endpoint_name TEXT NOT NULL,
    external_id TEXT,
    season TEXT,
    fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    payload_json JSONB NOT NULL,
    payload_hash TEXT,
    parse_status TEXT NOT NULL DEFAULT 'pending',  -- pending / parsed / error
    parse_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_stg_api_payloads_provider_sport_entity
    ON ops.stg_api_payloads(provider, sport_code, entity_type);

CREATE INDEX IF NOT EXISTS idx_stg_api_payloads_parse_status
    ON ops.stg_api_payloads(parse_status);


CREATE TABLE IF NOT EXISTS staging.stg_provider_leagues
(
    id BIGSERIAL PRIMARY KEY,
    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    external_league_id TEXT NOT NULL,
    league_name TEXT NOT NULL,
    country_name TEXT,
    season TEXT,
    raw_payload_id BIGINT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_stg_provider_leagues_provider_league_season
    ON ops.stg_provider_leagues(provider, external_league_id, season);


CREATE TABLE IF NOT EXISTS staging.stg_provider_teams
(
    id BIGSERIAL PRIMARY KEY,
    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    external_team_id TEXT NOT NULL,
    team_name TEXT NOT NULL,
    country_name TEXT,
    external_league_id TEXT,
    season TEXT,
    raw_payload_id BIGINT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_stg_provider_teams_provider_team
    ON ops.stg_provider_teams(provider, external_team_id);


CREATE TABLE IF NOT EXISTS staging.stg_provider_players
(
    id BIGSERIAL PRIMARY KEY,
    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    external_player_id TEXT NOT NULL,
    player_name TEXT NOT NULL,
    birth_date DATE,
    nationality TEXT,
    external_team_id TEXT,
    season TEXT,
    raw_payload_id BIGINT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_stg_provider_players_provider_player
    ON ops.stg_provider_players(provider, external_player_id);


CREATE TABLE IF NOT EXISTS staging.stg_provider_fixtures
(
    id BIGSERIAL PRIMARY KEY,
    provider TEXT NOT NULL,
    sport_code TEXT NOT NULL,
    external_fixture_id TEXT NOT NULL,
    external_league_id TEXT,
    season TEXT,
    home_team_external_id TEXT,
    away_team_external_id TEXT,
    fixture_date TIMESTAMPTZ,
    status_text TEXT,
    home_score TEXT,
    away_score TEXT,
    raw_payload_id BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_stg_provider_fixtures_provider_fixture
    ON ops.stg_provider_fixtures(provider, external_fixture_id);