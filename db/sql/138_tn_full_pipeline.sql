-- =========================================================
-- 138_tn_full_pipeline.sql
-- MATCHMATRIX - TN FULL PIPELINE
-- =========================================================

select
    'TN' as sport,
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
where ext_source = 'api_tennis';

-- =========================================================
-- 2) TEAMS (PLAYERS) CHECK
-- =========================================================
select
    'TEAMS' as entity,
    count(*) as cnt
from public.team_provider_map
where provider = 'api_tennis';

-- =========================================================
-- 3) MATCHES CHECK
-- =========================================================
select
    'MATCHES' as entity,
    count(*) as cnt
from public.matches
where ext_source = 'api_tennis';

-- =========================================================
-- 4) ODDS CHECK
-- =========================================================
select
    'ODDS' as entity,
    count(*) as cnt
from public.odds o
join public.matches m on m.id = o.match_id
where m.ext_source = 'api_tennis';

-- =========================================================
-- 5) RAW PAYLOAD CHECK
-- =========================================================
select
    'RAW_ODDS' as entity,
    count(*) as cnt
from public.api_raw_payloads
where source = 'api_tennis';

-- =========================================================
-- 6) STAGING CHECK
-- =========================================================
select 'STG_FIXTURES', count(*) from staging.api_tennis_fixtures
union all
select 'STG_LEAGUES', count(*) from staging.api_tennis_leagues;

-- =========================================================
-- 7) FINAL STATUS
-- =========================================================
select
    case
        when
            (select count(*) from public.leagues where ext_source = 'api_tennis') > 0
        and (select count(*) from public.team_provider_map where provider = 'api_tennis') > 0
        and (select count(*) from public.matches where ext_source = 'api_tennis') > 0
        and (select count(*) from public.odds o join public.matches m on m.id = o.match_id where m.ext_source = 'api_tennis') > 0
        then 'TN FULL PIPELINE = OK'
        else 'TN FULL PIPELINE = NOT OK'
    end as result;