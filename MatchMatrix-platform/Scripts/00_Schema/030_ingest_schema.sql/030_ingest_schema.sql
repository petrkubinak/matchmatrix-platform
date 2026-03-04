create table if not exists public.api_import_runs (
  id bigserial primary key,
  source text not null,              -- 'football_data' | 'the_odds_api' | 'api_football' ...
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  status text not null default 'running', -- running|ok|error
  details jsonb
);

create table if not exists public.api_raw_payloads (
  id bigserial primary key,
  run_id bigint not null references public.api_import_runs(id) on delete cascade,
  source text not null,
  endpoint text not null,
  fetched_at timestamptz not null default now(),
  payload jsonb not null
);

create index if not exists ix_api_raw_payloads_run on public.api_raw_payloads(run_id);
