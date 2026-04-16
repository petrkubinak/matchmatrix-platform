-- 601_fb_coaches_mapping_data_gap.sql
-- Účel:
-- zjistit, kde přesně se láme FB coaches mapping:
-- 1) jestli máme data ve stagingu
-- 2) kolik coachů už je namapovaných
-- 3) kolik řádků nemá team match přes team_provider_map
-- Spouštět v DBeaveru

-- 1) základní stav stagingu pro FB coaches
select
    provider,
    sport_code,
    count(*) as stg_rows,
    count(distinct external_coach_id) as distinct_external_coaches,
    count(distinct team_external_id) as distinct_team_external_ids,
    count(distinct league_external_id) as distinct_league_external_ids
from staging.stg_provider_coaches
where sport_code = 'FB'
group by provider, sport_code
order by provider;

-- 2) kolik coach provider map už existuje pro FB provider rows
select
    s.provider,
    count(*) as stg_rows,
    count(cpm.coach_id) as mapped_coach_rows,
    count(*) - count(cpm.coach_id) as unmapped_coach_rows
from staging.stg_provider_coaches s
left join public.coach_provider_map cpm
    on cpm.provider = s.provider
   and cpm.provider_coach_id = s.external_coach_id
where s.sport_code = 'FB'
group by s.provider
order by s.provider;

-- 3) kolik team mappingů existuje
select
    s.provider,
    count(*) as stg_rows,
    count(tpm.team_id) as mapped_team_rows,
    count(*) - count(tpm.team_id) as unmapped_team_rows
from staging.stg_provider_coaches s
left join public.team_provider_map tpm
    on tpm.provider = s.provider
   and tpm.provider_team_id = s.team_external_id
where s.sport_code = 'FB'
group by s.provider
order by s.provider;

-- 4) detail prvních nenamapovaných team rows
select
    s.provider,
    s.external_coach_id,
    s.coach_name,
    s.team_external_id,
    s.team_name,
    s.league_external_id,
    s.league_name,
    s.season
from staging.stg_provider_coaches s
left join public.team_provider_map tpm
    on tpm.provider = s.provider
   and tpm.provider_team_id = s.team_external_id
where s.sport_code = 'FB'
  and tpm.team_id is null
order by s.provider, s.team_name, s.coach_name
limit 100;

-- 5) detail prvních nenamapovaných coach rows
select
    s.provider,
    s.external_coach_id,
    s.coach_name,
    s.first_name,
    s.last_name,
    s.team_name,
    s.season
from staging.stg_provider_coaches s
left join public.coach_provider_map cpm
    on cpm.provider = s.provider
   and cpm.provider_coach_id = s.external_coach_id
where s.sport_code = 'FB'
  and cpm.coach_id is null
order by s.provider, s.coach_name
limit 100;