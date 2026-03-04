alter table public.bookmakers
  add column if not exists ext_source text,
  add column if not exists ext_bookmaker_key text;

create index if not exists ix_bookmakers_ext on public.bookmakers(ext_source, ext_bookmaker_key);
