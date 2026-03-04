-- 022_parse_api_hockey_teams_raw.sql
-- RAW (jsonb) -> parsed staging.api_hockey_teams

create table if not exists staging.api_hockey_teams (
  run_id     int not null,
  fetched_at timestamptz not null,
  league_id  int null,          -- provider league id (z requestu nebo z payloadu)
  season     int null,
  team_id    int not null,      -- provider team id
  name       text null,
  code       text null,
  country    text null,
  founded    int null,
  national   boolean null,
  logo       text null,
  raw        jsonb not null
);

create unique index if not exists uq_api_hockey_teams
  on staging.api_hockey_teams (run_id, team_id);

-- !!! Parse: struktura API-Hockey se může mírně lišit, ale typicky response je pole objektů "team" nebo rovnou tým.
-- Níže je robustní varianta: vezme team objekt pokud existuje, jinak bere item jako team.
insert into staging.api_hockey_teams (
  run_id, fetched_at, league_id, season,
  team_id, name, code, country, founded, national, logo, raw
)
select
  r.run_id,
  r.fetched_at,
  nullif((r.payload->'parameters'->>'league'),'')::int as league_id,
  nullif((r.payload->'parameters'->>'season'),'')::int as season,

  (coalesce(item->'team', item)->>'id')::int as team_id,
  coalesce(item->'team', item)->>'name' as name,
  coalesce(item->'team', item)->>'code' as code,
  coalesce(item->'team', item)->>'country' as country,
  nullif(coalesce(item->'team', item)->>'founded','')::int as founded,
  nullif(coalesce(item->'team', item)->>'national','')::boolean as national,
  coalesce(item->'team', item)->>'logo' as logo,

  item as raw
from staging.api_hockey_teams_raw r
cross join lateral jsonb_array_elements(r.payload->'response') as item
where r.run_id = 3
  and (coalesce(item->'team', item)->>'id') is not null
on conflict do nothing;