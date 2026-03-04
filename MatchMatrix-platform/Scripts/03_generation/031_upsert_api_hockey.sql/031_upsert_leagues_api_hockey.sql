-- 031_upsert_leagues_api_hockey.sql
-- staging.api_hockey_leagues → public.leagues
-- provider: api_hockey
-- deduplikace přes GROUP BY league_id

insert into public.leagues (
  sport_id,
  name,
  country,
  country_id,
  is_cup,
  is_international,
  ext_source,
  ext_league_id,
  created_at,
  updated_at
)
select
  s.id,
  max(st.name) as name,
  max(st.country) as country,
  max(c.id) as country_id,
  bool_or(st.is_cup) as is_cup,
  bool_or(st.is_international) as is_international,
  'api_hockey',
  st.league_id::text,
  now(),
  now()
from staging.api_hockey_leagues st
join public.sports s
  on s.code = 'HK'
left join public.countries c
  on c.iso2 = st.country_code
group by st.league_id, s.id
on conflict (ext_source, ext_league_id) do update
set
  name = excluded.name,
  country = excluded.country,
  country_id = excluded.country_id,
  is_cup = excluded.is_cup,
  is_international = excluded.is_international,
  updated_at = now();