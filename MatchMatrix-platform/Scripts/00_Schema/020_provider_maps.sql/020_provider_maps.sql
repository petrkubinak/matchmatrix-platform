-- 00_Schema/20_provider_maps.sql

-- (volitelné) seznam providerů, ať jsou hodnoty konzistentní
create table if not exists public.data_providers (
  code text primary key,        -- 'football_data', 'api_football', 'the_odds'
  name text not null
);

insert into public.data_providers(code, name) values
  ('football_data', 'Football-Data (legacy)'),
  ('api_football',  'API-Football (API-Sports v3)'),
  ('the_odds',      'The Odds API')
on conflict (code) do nothing;


-- mapování canonical ligy na provider league_id
create table if not exists public.league_provider_map (
  league_id bigint not null references public.leagues(id) on delete cascade,
  provider  text not null references public.data_providers(code),
  provider_league_id text not null,   -- text kvůli různým providerům (někde číslo, někde string)
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (league_id, provider)
);

-- aby jeden provider_league_id nemohl mapovat na víc canonical lig
create unique index if not exists ux_league_provider_map_provider_id
  on public.league_provider_map(provider, provider_league_id);