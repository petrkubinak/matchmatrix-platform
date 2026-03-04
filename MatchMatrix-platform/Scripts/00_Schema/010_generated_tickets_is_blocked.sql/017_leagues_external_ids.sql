alter table public.leagues
  add column if not exists ext_source text,
  add column if not exists ext_league_id text;

create unique index if not exists uq_leagues_ext
  on public.leagues(ext_source, ext_league_id);
