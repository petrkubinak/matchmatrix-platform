-- 137_bsb_full_pipeline.sql

-- MATCHMATRIX - BSB FULL PIPELINE

select
    'BSB' as sport,
    'core_pipeline' as pipeline,
    'DONE' as status,
    now() as executed_at;

-- =========================================================
-- 1) LEAGUES CHECK
-- =========================================================
select
    'LEAGUES' as entity,
    count(*) as cnt
from public.leagues
where ext_source = 'api_baseball';

-- =========================================================
-- 2) TEAMS CHECK
-- =========================================================
select
    'TEAMS' as entity,
    count(*) as cnt
from public.team_provider_map
where provider = 'api_baseball';

-- =========================================================
-- 3) FIXTURES CHECK
-- =========================================================
select
    'MATCHES' as entity,
    count(*) as cnt
from public.matches
where ext_source = 'api_baseball';

-- =========================================================
-- 4) STAGING CHECK
-- =========================================================
select 'STG_TEAMS', count(*) from staging.stg_provider_teams where provider = 'api_baseball'
union all
select 'STG_FIXTURES', count(*) from staging.stg_provider_fixtures where provider = 'api_baseball'
union all
select 'STG_LEAGUES', count(*) from staging.stg_provider_leagues where provider = 'api_baseball';

-- =========================================================
-- 5) FINAL STATUS
-- =========================================================
select
    case
        when
            (select count(*) from public.leagues where ext_source = 'api_baseball') > 0
        and (select count(*) from public.team_provider_map where provider = 'api_baseball') > 0
        and (select count(*) from public.matches where ext_source = 'api_baseball') > 0
        then 'BSB FULL PIPELINE = OK'
        else 'BSB FULL PIPELINE = NOT OK'
    end as result;