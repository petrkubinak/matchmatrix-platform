-- 705_create_stg_api_american_football_fixtures.sql
-- AFB fixtures - staging table
-- Spoustet v DBeaveru

create schema if not exists staging;

create table if not exists staging.stg_api_american_football_fixtures (
    id bigserial primary key,
    run_ts timestamptz not null default now(),

    provider text not null default 'api_american_football',
    league_id text,
    season text,

    provider_game_id text not null,
    provider_league_id text,
    provider_league_name text,
    game_date timestamp,
    game_status_short text,
    game_status_long text,

    home_team_id text,
    home_team_name text,
    away_team_id text,
    away_team_name text,

    home_score integer,
    away_score integer,

    raw_json jsonb not null
);

create index if not exists ix_stg_aaf_fixtures_game_id
    on staging.stg_api_american_football_fixtures(provider_game_id);

create index if not exists ix_stg_aaf_fixtures_league_season
    on staging.stg_api_american_football_fixtures(league_id, season);

create index if not exists ix_stg_aaf_fixtures_home_away
    on staging.stg_api_american_football_fixtures(home_team_id, away_team_id);