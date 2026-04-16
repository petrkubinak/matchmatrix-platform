-- 608_fb_coaches_team_mapping_check.sql
-- Účel:
-- ověřit mapování staging coaches -> public teams přes provider_team_id
-- Spouštět v DBeaveru

drop table if exists tmp_fb_coaches_mapped;

create temp table tmp_fb_coaches_mapped as
select
    c.id,
    c.external_coach_id,
    c.coach_name,
    c.team_external_id,
    c.team_name,
    tpm.team_id,
    t.name as canonical_team_name
from staging.stg_provider_coaches c
left join public.team_provider_map tpm
    on tpm.provider = 'api_football'
   and tpm.provider_team_id = c.team_external_id
left join public.teams t
    on t.id = tpm.team_id
where c.provider = 'api_football'
  and c.sport_code = 'FB'
  and c.external_coach_id is not null;

-- 1) summary
select
    count(*) as total_rows,
    count(*) filter (where team_id is not null) as mapped_rows,
    count(*) filter (where team_id is null) as unmapped_rows
from tmp_fb_coaches_mapped;

-- 2) detail unmapped
select
    id,
    external_coach_id,
    coach_name,
    team_external_id,
    team_name,
    team_id,
    canonical_team_name
from tmp_fb_coaches_mapped
where team_id is null
order by team_name, coach_name
limit 100;

-- 3) detail mapped
select
    id,
    external_coach_id,
    coach_name,
    team_external_id,
    team_name,
    team_id,
    canonical_team_name
from tmp_fb_coaches_mapped
where team_id is not null
order by team_name, coach_name
limit 100;