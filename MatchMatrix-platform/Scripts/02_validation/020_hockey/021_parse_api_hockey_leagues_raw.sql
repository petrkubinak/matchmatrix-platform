-- 021_parse_api_hockey_leagues_raw.sql
-- API-Hockey leagues RAW -> staging parsed (root schema)

insert into staging.api_hockey_teams (
  run_id,
  fetched_at,
  league_id,
  season,
  team_id,
  name,
  code,
  country,
  founded,
  national,
  logo,
  raw
)
select
  r.run_id,
  r.fetched_at,
  nullif(r.payload->'parameters'->>'league','')::int as league_id,
  nullif(r.payload->'parameters'->>'season','')::int as season,

  coalesce(
    nullif(item->'team'->>'id','')::int,
    nullif(item->>'id','')::int
  ) as team_id,

  coalesce(item->'team'->>'name', item->>'name') as name,
  coalesce(item->'team'->>'code', item->>'code') as code,
  coalesce(item->'team'->>'country', item->>'country') as country,
  nullif(coalesce(item->'team'->>'founded', item->>'founded'), '')::int as founded,
  nullif(coalesce(item->'team'->>'national', item->>'national'), '')::boolean as national,
  coalesce(item->'team'->>'logo', item->>'logo') as logo,

  item as raw
from staging.api_hockey_teams_raw r
cross join lateral jsonb_array_elements(r.payload->'response') item
where r.run_id = 3
  and jsonb_array_length(r.payload->'response') > 0
  and coalesce(item->'team'->>'id', item->>'id') is not null
on conflict do nothing;

