-- 702_create_stg_api_american_football_teams.sql
-- AFB teams - staging table
-- Spoustet v DBeaveru

create schema if not exists staging;

create table if not exists staging.stg_api_american_football_teams (
    id bigserial primary key,
    run_ts timestamptz not null default now(),

    provider text not null default 'api_american_football',
    league_id text,
    season text,

    provider_team_id text not null,
    team_name text not null,
    team_code text,
    city text,
    coach text,
    owner text,
    stadium text,
    established integer,
    logo_url text,

    country_name text,
    country_code text,
    country_flag_url text,

    raw_json jsonb not null
);

create index if not exists ix_stg_aaf_teams_provider_team_id
    on staging.stg_api_american_football_teams(provider_team_id);

create index if not exists ix_stg_aaf_teams_league_season
    on staging.stg_api_american_football_teams(league_id, season);