-- 609_fb_missing_team_provider_map_check.sql
-- Účel:
-- ověřit chybějící team_provider_map pro FB coaches unmapped týmy
-- Spouštět v DBeaveru

-- 1) staging týmy z coaches, které se teď netrefily
with coach_teams as (
    select distinct
        team_external_id,
        team_name
    from staging.stg_provider_coaches
    where provider = 'api_football'
      and sport_code = 'FB'
      and external_coach_id is not null
),
mapped as (
    select
        ct.team_external_id,
        ct.team_name,
        tpm.team_id,
        t.name as canonical_team_name
    from coach_teams ct
    left join public.team_provider_map tpm
        on tpm.provider = 'api_football'
       and tpm.provider_team_id = ct.team_external_id
    left join public.teams t
        on t.id = tpm.team_id
)
select *
from mapped
order by team_name;

-- 2) zkusit dohledat stejné názvy v public.teams
with coach_teams as (
    select distinct
        team_external_id,
        team_name
    from staging.stg_provider_coaches
    where provider = 'api_football'
      and sport_code = 'FB'
      and external_coach_id is not null
),
unmapped as (
    select
        ct.team_external_id,
        ct.team_name
    from coach_teams ct
    left join public.team_provider_map tpm
        on tpm.provider = 'api_football'
       and tpm.provider_team_id = ct.team_external_id
    where tpm.team_id is null
)
select
    u.team_external_id,
    u.team_name as provider_team_name,
    t.id as candidate_team_id,
    t.name as candidate_team_name
from unmapped u
left join public.teams t
    on lower(t.name) = lower(u.team_name)
order by u.team_name, t.name;

-- 3) zkusit i aliasové/stem kandidáty volněji
with coach_teams as (
    select distinct
        team_external_id,
        team_name
    from staging.stg_provider_coaches
    where provider = 'api_football'
      and sport_code = 'FB'
      and external_coach_id is not null
),
unmapped as (
    select
        ct.team_external_id,
        ct.team_name
    from coach_teams ct
    left join public.team_provider_map tpm
        on tpm.provider = 'api_football'
       and tpm.provider_team_id = ct.team_external_id
    where tpm.team_id is null
)
select
    u.team_external_id,
    u.team_name as provider_team_name,
    t.id as candidate_team_id,
    t.name as candidate_team_name
from unmapped u
join public.teams t
    on lower(t.name) like '%' || lower(u.team_name) || '%'
    or lower(u.team_name) like '%' || lower(t.name) || '%'
order by u.team_name, t.name;