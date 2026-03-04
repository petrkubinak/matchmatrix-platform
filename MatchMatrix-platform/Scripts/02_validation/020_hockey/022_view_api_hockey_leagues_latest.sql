create or replace view staging.v_api_hockey_leagues_latest as
select distinct on (league_id, season)
  run_id, fetched_at,
  league_id, season,
  name, type, country, country_code, logo,
  is_cup, is_international,
  raw
from staging.api_hockey_leagues
order by league_id, season, fetched_at desc, run_id desc;