alter table public.teams
  add column if not exists ext_source text,
  add column if not exists ext_team_id text;

create unique index if not exists uq_teams_ext
  on public.teams(ext_source, ext_team_id);
