-- 724_insert_public_leagues_bsb_core.sql

insert into public.leagues (
    sport_id,
    name,
    country,
    ext_source,
    ext_league_id,
    is_active,
    created_at,
    updated_at
)
select
    s.id as sport_id,
    spl.league_name as name,
    spl.country_name as country,
    'api_baseball' as ext_source,
    spl.external_league_id as ext_league_id,
    coalesce(spl.is_active, true) as is_active,
    now() as created_at,
    now() as updated_at
from staging.stg_provider_leagues spl
join public.sports s
    on lower(s.code) = lower('BSB')
where spl.provider = 'api_baseball'
  and not exists (
      select 1
      from public.leagues l
      where l.ext_source = 'api_baseball'
        and l.ext_league_id = spl.external_league_id
  );