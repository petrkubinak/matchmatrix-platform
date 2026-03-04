-- 00_Schema/30_ops_admin.sql
create schema if not exists ops;

-- Ingest cíle (DB-driven konfigurace)
create table if not exists ops.ingest_targets (
  id bigserial primary key,
  sport_code text not null,                  -- 'football', 'hockey', 'basketball'...
  canonical_league_id bigint not null references public.leagues(id) on delete cascade,
  provider text not null,                    -- 'api_football', 'football_data', 'theodds'
  provider_league_id text not null,          -- např. '39'
  season text not null default '',           -- vždy NOT NULL => jednodušší unique
  enabled boolean not null default true,
  tier int not null default 1,               -- 1=top, 2=střed, 3=okraj
  fixtures_days_back int not null default 7,
  fixtures_days_forward int not null default 14,
  odds_days_forward int not null default 3,
  max_requests_per_run int,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (provider, provider_league_id, season)
);

create index if not exists ix_ops_ingest_targets_enabled
  on ops.ingest_targets(enabled, provider, sport_code, tier);

-- Definice jobů
create table if not exists ops.jobs (
  code text primary key,
  name text not null,
  description text,
  recommended text,
  enabled boolean not null default true,
  default_params jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Historie běhů jobů
create table if not exists ops.job_runs (
  id bigserial primary key,
  job_code text not null references ops.jobs(code),
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  status text not null default 'running',    -- running|success|failed
  params jsonb not null default '{}'::jsonb,
  message text,
  details jsonb not null default '{}'::jsonb,
  api_import_run_id bigint,
  rows_affected bigint,
  created_at timestamptz not null default now()
);

create index if not exists ix_ops_job_runs_recent
  on ops.job_runs(job_code, started_at desc);

-- Seed jobů
insert into ops.jobs(code, name, description, recommended, default_params) values
('ingest_fixtures', 'Ingest Fixtures', 'Stáhne fixtures a naplní staging + merge do matches', 'denně 1–3×', '{}'::jsonb),
('ingest_odds', 'Ingest Odds', 'Stáhne odds a naplní staging + merge do odds', 'denně 2–6× (dle limitů)', '{}'::jsonb),
('ingest_teams', 'Ingest Teams', 'Aktualizace týmů (nebo jen chybějící)', 'týdně nebo on-demand', '{}'::jsonb),
('calc_ratings', 'Přepočet ratingů', 'mm_team_ratings + mm_match_ratings', 'denně 1× (po fixtures)', '{}'::jsonb),
('calc_predictions', 'Predikce + value', 'ml_predictions + fair/value views', 'denně (po odds)', '{}'::jsonb),
('daily_healthcheck', 'Healthcheck', 'Kontroly kvality dat + report', 'denně 1×', '{}'::jsonb)
on conflict (code) do nothing;