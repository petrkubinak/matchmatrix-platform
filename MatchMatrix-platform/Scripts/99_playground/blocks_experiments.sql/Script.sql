-- =========================
-- MATCHMATRIX CORE SCHEMA v1
-- =========================

CREATE TABLE sports (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL
);

CREATE TABLE leagues (
    id SERIAL PRIMARY KEY,
    sport_id INT REFERENCES sports(id),
    name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE matches (
    id SERIAL PRIMARY KEY,
    league_id INT REFERENCES leagues(id),
    home_team_id INT REFERENCES teams(id),
    away_team_id INT REFERENCES teams(id),
    kickoff TIMESTAMP NOT NULL
);

CREATE TABLE bookmakers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    region TEXT
);

CREATE TABLE markets (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL
);

CREATE TABLE market_outcomes (
    id SERIAL PRIMARY KEY,
    market_id INT REFERENCES markets(id),
    code TEXT NOT NULL,
    label TEXT NOT NULL
);

CREATE TABLE odds (
    id SERIAL PRIMARY KEY,
    match_id INT REFERENCES matches(id),
    bookmaker_id INT REFERENCES bookmakers(id),
    market_outcome_id INT REFERENCES market_outcomes(id),
    odd_value NUMERIC(6,3) NOT NULL,
    collected_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE templates (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    max_variable_blocks INT NOT NULL
);

CREATE TABLE template_blocks (
    id SERIAL PRIMARY KEY,
    template_id INT REFERENCES templates(id),
    block_index INT NOT NULL,
    block_type TEXT CHECK (block_type IN ('FIXED','VARIABLE')) NOT NULL
);

CREATE TABLE generated_runs (
    id SERIAL PRIMARY KEY,
    template_id INT REFERENCES templates(id),
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE generated_tickets (
    id SERIAL PRIMARY KEY,
    run_id INT REFERENCES generated_runs(id),
    ticket_index INT NOT NULL,
    probability NUMERIC(6,4),
    snapshot JSONB NOT NULL
);
