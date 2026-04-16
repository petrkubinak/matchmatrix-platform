-- 607_cleanup_bad_fb_coaches_stage_rows.sql
-- Účel:
-- odstranit chybné testovací FB coach rows ze staré verze ingestu
-- Spouštět v DBeaveru

delete from staging.stg_provider_coaches
where provider = 'api_football'
  and sport_code = 'FB'
  and external_coach_id is null;

select
    provider,
    sport_code,
    external_coach_id,
    coach_name,
    first_name,
    last_name,
    nationality,
    team_external_id,
    team_name,
    birth_date,
    birth_place,
    birth_country
from staging.stg_provider_coaches
where provider = 'api_football'
  and sport_code = 'FB'
order by id desc
limit 50;