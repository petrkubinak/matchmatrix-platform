alter table public.leagues
  add column if not exists ext_source text,
  add column if not exists ext_league_id text;

alter table public.teams
  add column if not exists ext_source text,
  add column if not exists ext_team_id text;

alter table public.matches
  add column if not exists ext_source text,
  add column if not exists ext_match_id text;

create index if not exists ix_leagues_ext on public.leagues(ext_source, ext_league_id);
create index if not exists ix_teams_ext on public.teams(ext_source, ext_team_id);
create index if not exists ix_matches_ext on public.matches(ext_source, ext_match_id);
