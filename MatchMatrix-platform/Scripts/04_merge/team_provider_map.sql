insert into public.team_provider_map (team_id, provider, provider_team_id)
select
    t.id as team_id,
    'api_football' as provider,
    st.team_id::text as provider_team_id
from staging.api_football_teams st
join public.teams t
  on t.ext_source = 'api_football'
 and t.ext_team_id = st.team_id::text
where st.run_id = 112
on conflict (provider, provider_team_id) do update
set team_id = excluded.team_id,
    updated_at = now();