-- 00_Schema/10_staging_api_football.sql
create schema if not exists staging;

-- Import run summary (pokud už nemáte podobné, můžete vynechat)
-- api_import_runs už existuje dle ERD/kontextu.

create table if not exists staging.api_football_leagues (
  run_id       bigint not null,
  league_id    int not null,          -- API league.id
  season       int,                   -- API někdy vrací seasons list; sem dáme “aktuální” nebo null
  name         text not null,
  type         text,
  country      text,
  country_code text,
  is_cup       boolean,
  is_international boolean,
  logo         text,
  raw          jsonb not null,
  fetched_at   timestamptz not null default now(),
  primary key (run_id, league_id)
);

create table if not exists staging.api_football_teams (
  run_id       bigint not null,
  league_id    int not null,
  season       int not null,
  team_id      int not null,          -- API team.id
  name         text not null,
  code         text,
  country      text,
  founded      int,
  national     boolean,
  logo         text,
  venue_name   text,
  venue_city   text,
  raw          jsonb not null,
  fetched_at   timestamptz not null default now(),
  primary key (run_id, league_id, season, team_id)
);

create table if not exists staging.api_football_fixtures (
  run_id       bigint not null,
  league_id    int not null,
  season       int not null,
  fixture_id   int not null,          -- API fixture.id
  kickoff      timestamptz,
  status       text,
  home_team_id int,
  away_team_id int,
  home_goals   int,
  away_goals   int,
  raw          jsonb not null,
  fetched_at   timestamptz not null default now(),
  primary key (run_id, league_id, season, fixture_id)
);

-- Odds (až později, ale schema připravíme)
create table if not exists staging.api_football_odds (
  run_id        bigint not null,
  league_id     int not null,
  season        int not null,
  fixture_id    int not null,
  bookmaker_id  int,
  market        text,
  outcome       text,
  odd_value     numeric,
  raw           jsonb not null,
  fetched_at    timestamptz not null default now(),
  primary key (run_id, league_id, season, fixture_id, bookmaker_id, market, outcome)
);

create index if not exists ix_stg_af_teams_lookup
  on staging.api_football_teams (league_id, season, team_id);

create index if not exists ix_stg_af_fix_kickoff
  on staging.api_football_fixtures (league_id, season, kickoff);