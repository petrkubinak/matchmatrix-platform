CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.api_hockey_leagues (
  run_id      bigint NOT NULL,
  league_id   int4   NOT NULL,
  season      int4   NULL,
  name        text   NULL,
  type        text   NULL,
  country     text   NULL,
  country_code text  NULL,
  logo        text   NULL,
  is_cup      bool   NULL,
  is_international bool NULL,
  raw         jsonb  NOT NULL,
  fetched_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_api_hockey_leagues_run ON staging.api_hockey_leagues(run_id);
CREATE INDEX IF NOT EXISTS ix_api_hockey_leagues_league ON staging.api_hockey_leagues(league_id);
