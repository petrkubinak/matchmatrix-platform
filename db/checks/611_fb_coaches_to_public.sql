-- 611_fb_coaches_to_public.sql
-- Bezpečná verze: staging -> public.coaches + coach_provider_map

-- 0) cleanup špatných testovacích staging rows
delete from staging.stg_provider_coaches
where provider = 'api_football'
  and sport_code = 'FB'
  and (
      external_coach_id is null
      or coach_name is null
      or btrim(coach_name) = ''
  );

-- 1) INSERT coaches
insert into public.coaches (
    name,
    first_name,
    last_name,
    nationality,
    birth_date,
    birth_place,
    birth_country,
    photo_url,
    is_active,
    created_at,
    updated_at
)
select distinct
    c.coach_name,
    c.first_name,
    c.last_name,
    c.nationality,
    c.birth_date,
    c.birth_place,
    c.birth_country,
    c.photo_url,
    true,
    now(),
    now()
from staging.stg_provider_coaches c
where c.provider = 'api_football'
  and c.sport_code = 'FB'
  and c.external_coach_id is not null
  and c.coach_name is not null
  and btrim(c.coach_name) <> ''
  and not exists (
        select 1
        from public.coaches pc
        where lower(pc.name) = lower(c.coach_name)
  );

-- 2) INSERT coach provider map
insert into public.coach_provider_map (
    coach_id,
    provider,
    provider_coach_id,
    confidence,
    is_primary,
    is_active,
    created_at,
    updated_at
)
select
    pc.id,
    'api_football',
    src.external_coach_id,
    1.0,
    true,
    true,
    now(),
    now()
from (
    select distinct
        external_coach_id,
        coach_name
    from staging.stg_provider_coaches
    where provider = 'api_football'
      and sport_code = 'FB'
      and external_coach_id is not null
      and coach_name is not null
      and btrim(coach_name) <> ''
) src
join public.coaches pc
    on lower(pc.name) = lower(src.coach_name)
where not exists (
    select 1
    from public.coach_provider_map m
    where m.provider = 'api_football'
      and m.provider_coach_id = src.external_coach_id
);

-- 3) kontrola
select count(*) as coaches_cnt from public.coaches;
select count(*) as coach_provider_map_cnt from public.coach_provider_map;

select
    id,
    name,
    first_name,
    last_name,
    nationality
from public.coaches
order by id desc
limit 20;

select
    provider,
    provider_coach_id,
    coach_id
from public.coach_provider_map
where provider = 'api_football'
order by id desc
limit 20;