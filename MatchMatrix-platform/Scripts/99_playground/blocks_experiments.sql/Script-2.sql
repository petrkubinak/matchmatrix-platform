BEGIN;

CREATE TABLE sports (
  id SERIAL PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE leagues (
  id SERIAL PRIMARY KEY,
  sport_id INT NOT NULL REFERENCES sports(id),
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
  home_team_id INT NOT NULL REFERENCES teams(id),
  away_team_id INT NOT NULL REFERENCES teams(id),
  kickoff TIMESTAMP NOT NULL,
  CONSTRAINT chk_teams_different CHECK (home_team_id <> away_team_id)
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
  market_id INT NOT NULL REFERENCES markets(id),
  code TEXT NOT NULL,
  label TEXT NOT NULL,
  UNIQUE (market_id, code)
);

CREATE TABLE odds (
  id SERIAL PRIMARY KEY,
  match_id INT NOT NULL REFERENCES matches(id),
  bookmaker_id INT NOT NULL REFERENCES bookmakers(id),
  market_outcome_id INT NOT NULL REFERENCES market_outcomes(id),
  odd_value NUMERIC(6,3) NOT NULL,
  collected_at TIMESTAMP NOT NULL DEFAULT now(),
  CONSTRAINT chk_odd_value CHECK (odd_value > 1.0)
);

CREATE TABLE templates (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  max_variable_blocks INT NOT NULL DEFAULT 4
);

CREATE TABLE template_blocks (
  id SERIAL PRIMARY KEY,
  template_id INT NOT NULL REFERENCES templates(id),
  block_index INT NOT NULL,
  block_type TEXT NOT NULL CHECK (block_type IN ('FIXED','VARIABLE')),
  UNIQUE (template_id, block_index)
);

CREATE TABLE generated_runs (
  id SERIAL PRIMARY KEY,
  template_id INT NOT NULL REFERENCES templates(id),
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE generated_tickets (
  id SERIAL PRIMARY KEY,
  run_id INT NOT NULL REFERENCES generated_runs(id),
  ticket_index INT NOT NULL,
  probability NUMERIC(6,4),
  snapshot JSONB NOT NULL,
  UNIQUE (run_id, ticket_index)
);

COMMIT;
