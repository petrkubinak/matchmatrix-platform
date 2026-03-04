--033_upsert_league_teams_api_hockey.sql

insert into public.league_teams (league_id, team_id, season, created_at, updated_at)
select distinct
  lm.league_id,
  tm.team_id,
  st.season,
  now(),
  now()
from staging.api_hockey_teams st
join public.league_provider_map lm
  on lm.provider='api_hockey'
 and lm.provider_league_id = st.league_id::text
join public.team_provider_map tm
  on tm.provider='api_hockey'
 and tm.provider_team_id = st.team_id::text
where st.run_id = 3
  and st.league_id is not null
on conflict do nothing;