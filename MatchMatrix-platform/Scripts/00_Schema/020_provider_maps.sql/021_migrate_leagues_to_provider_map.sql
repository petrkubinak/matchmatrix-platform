-- 01_Migrations/21_migrate_leagues_to_provider_map.sql

-- 1) přenést stávající ext_source/ext_league_id z public.leagues do mapy
insert into public.league_provider_map(league_id, provider, provider_league_id)
select
  id as league_id,
  ext_source as provider,
  ext_league_id::text as provider_league_id
from public.leagues
where ext_source is not null
  and ext_league_id is not null
on conflict (league_id, provider) do update
set provider_league_id = excluded.provider_league_id,
    updated_at = now();

-- 2) kontrola: duplicity provider_league_id napříč ligami (nemělo by nastat)
select provider, provider_league_id, count(*)
from public.league_provider_map
group by provider, provider_league_id
having count(*) > 1;