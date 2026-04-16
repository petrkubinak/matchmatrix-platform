-- 703_merge_api_american_football_teams_to_public.sql
-- AFB teams -> public.teams + team_provider_map
-- Spoustet v DBeaveru

begin;

-- 1) vloz nove tymy do public.teams
insert into public.teams (
    name,
    ext_source,
    ext_team_id
)
select
    s.team_name,
    'api_american_football',
    s.provider_team_id
from staging.stg_api_american_football_teams s
left join public.team_provider_map tpm
    on tpm.provider = 'api_american_football'
   and tpm.provider_team_id = s.provider_team_id
where tpm.team_id is null
group by
    s.team_name,
    s.provider_team_id;

-- 2) zaloz provider map pro vsechny staging rows, ktere jeste mapu nemaji
insert into public.team_provider_map (
    team_id,
    provider,
    provider_team_id
)
select
    t.id as team_id,
    'api_american_football' as provider,
    s.provider_team_id
from staging.stg_api_american_football_teams s
join public.teams t
  on t.ext_source = 'api_american_football'
 and t.ext_team_id = s.provider_team_id
left join public.team_provider_map tpm
  on tpm.team_id = t.id
 and tpm.provider = 'api_american_football'
 and tpm.provider_team_id = s.provider_team_id
where tpm.team_id is null
group by
    t.id,
    s.provider_team_id;

commit;

-- 3) kontrola vysledku
select
    count(*) as public_teams_count
from public.teams
where ext_source = 'api_american_football';

select
    count(*) as provider_map_count
from public.team_provider_map
where provider = 'api_american_football';

select
    t.id,
    t.name,
    t.ext_source,
    t.ext_team_id
from public.teams t
where t.ext_source = 'api_american_football'
order by t.name;

select
    tpm.team_id,
    t.name,
    tpm.provider,
    tpm.provider_team_id
from public.team_provider_map tpm
join public.teams t
  on t.id = tpm.team_id
where tpm.provider = 'api_american_football'
order by t.name;