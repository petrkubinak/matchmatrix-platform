-- 734_insert_public_teams_rgb_core.sql

-- =========================================================
-- 1) public.teams
-- =========================================================
insert into public.teams (
    name,
    ext_source,
    ext_team_id,
    created_at,
    updated_at,
    logo_url
)
select
    st.team_name as name,
    'api_rugby' as ext_source,
    st.external_team_id as ext_team_id,
    now(),
    now(),
    null as logo_url
from staging.stg_provider_teams st
where st.provider = 'api_rugby'
  and not exists (
      select 1
      from public.teams t
      where t.ext_source = 'api_rugby'
        and t.ext_team_id = st.external_team_id
  );

-- =========================================================
-- 2) public.team_provider_map
-- =========================================================
insert into public.team_provider_map (
    team_id,
    provider,
    provider_team_id,
    created_at,
    updated_at
)
select
    t.id as team_id,
    'api_rugby' as provider,
    st.external_team_id as provider_team_id,
    now(),
    now()
from staging.stg_provider_teams st
join public.teams t
  on t.ext_source = 'api_rugby'
 and t.ext_team_id = st.external_team_id
where st.provider = 'api_rugby'
  and not exists (
      select 1
      from public.team_provider_map m
      where m.provider = 'api_rugby'
        and m.provider_team_id = st.external_team_id
  );