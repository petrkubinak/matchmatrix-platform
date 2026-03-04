select count(*) 
from staging.api_hockey_teams_raw
where run_id = 2;

select
  jsonb_typeof(payload->'response') as resp_type,
  payload->'response'->0 as first_item
from staging.api_hockey_teams_raw
where run_id = 2
limit 1;

select count(*) from public.teams where ext_source='api_hockey';
select count(*) from public.team_provider_map where provider='api_hockey';

select count(*) 
from public.league_teams lt
join public.leagues l on l.id=lt.league_id
where l.ext_source='api_hockey';

select
  count(*) as raw_rows,
  sum(jsonb_array_length(payload->'response')) as total_items,
  min(jsonb_array_length(payload->'response')) as min_items,
  max(jsonb_array_length(payload->'response')) as max_items
from staging.api_hockey_teams_raw
where run_id = 2;

select
  payload->'parameters' as params,
  payload->'errors' as errors,
  payload->'results' as results,
  payload->'response' as response
from staging.api_hockey_teams_raw
where run_id = 2
limit 266;

select
  count(*) as raw_rows,
  sum(jsonb_array_length(payload->'response')) as total_items,
  min(jsonb_array_length(payload->'response')) as min_items,
  max(jsonb_array_length(payload->'response')) as max_items
from staging.api_hockey_teams_raw
where run_id = 3;

select
  count(*) as items_total,
  count(*) filter (where (item ? 'team')) as items_with_team,
  count(*) filter (where not (item ? 'team') and (item ? 'id')) as items_with_id_only,
  count(*) filter (where coalesce(item->'team'->>'id', item->>'id') is null) as items_without_id
from staging.api_hockey_teams_raw r
cross join lateral jsonb_array_elements(r.payload->'response') item
where r.run_id = 3;

select count(*) from staging.api_hockey_teams where run_id = 3;
select count(distinct team_id) from staging.api_hockey_teams where run_id = 3;