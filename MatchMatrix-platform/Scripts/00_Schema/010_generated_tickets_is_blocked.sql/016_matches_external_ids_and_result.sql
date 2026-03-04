alter table public.matches
  add column if not exists ext_source text,
  add column if not exists ext_match_id text,
  add column if not exists status text,
  add column if not exists home_score int,
  add column if not exists away_score int,
  add column if not exists season text;

create unique index if not exists uq_matches_ext
  on public.matches(ext_source, ext_match_id);
