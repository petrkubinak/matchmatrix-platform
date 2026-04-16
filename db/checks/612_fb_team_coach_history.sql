-- 612_fb_team_coach_history.sql
-- Účel:
-- vytvořit team_coach_history z API-Football coaches career

insert into public.team_coach_history (
    team_id,
    coach_id,
    sport_id,
    start_date,
    end_date,
    is_current,
    provider,
    provider_coach_id,
    provider_team_id,
    confidence_score,
    created_at,
    updated_at
)
select
    tpm.team_id,
    pc.id as coach_id,
    1 as sport_id, -- FB
    c.start_date,
    c.end_date,
    case when c.end_date is null then true else false end,
    'api_football',
    c.external_coach_id,
    c.team_external_id,
    1.0,
    now(),
    now()
from (
    select
        sc.external_coach_id,
        sc.coach_name,
        sc.team_external_id,
        sc.team_name,
        sc.season,
        sc.created_at,

        -- ⚠️ TEMP workaround:
        -- API career nemáš ještě rozpadnutý na start/end ve stagingu
        null::date as start_date,
        null::date as end_date

    from staging.stg_provider_coaches sc
    where sc.provider = 'api_football'
      and sc.sport_code = 'FB'
      and sc.external_coach_id is not null
) c
join public.coaches pc
    on lower(pc.name) = lower(c.coach_name)
join public.team_provider_map tpm
    on tpm.provider = 'api_football'
   and tpm.provider_team_id = c.team_external_id
where not exists (
    select 1
    from public.team_coach_history h
    where h.provider = 'api_football'
      and h.provider_coach_id = c.external_coach_id
      and h.provider_team_id = c.team_external_id
);

-- kontrola
select count(*) as history_rows from public.team_coach_history;

select
    t.name as team,
    c.name as coach,
    h.start_date,
    h.end_date,
    h.is_current
from public.team_coach_history h
join public.teams t on t.id = h.team_id
join public.coaches c on c.id = h.coach_id
order by coach, team;