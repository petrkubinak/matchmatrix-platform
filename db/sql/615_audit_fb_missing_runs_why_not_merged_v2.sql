-- 615_audit_fb_missing_runs_why_not_merged_v2.sql
-- Účel:
-- Audit 6 API-Football runů přímo přes staging.api_football_fixtures,
-- protože v aktuální DB větvi zjevně není použitelné f.run_id ve staging.stg_provider_fixtures.
-- Spouštět v DBeaveru.

-- =========================================================
-- 0) CÍLOVÉ RUNY
-- =========================================================
with target_runs as (
    select 20260416223629048::bigint as run_id union all
    select 20260416220857378::bigint union all
    select 20260416223527869::bigint union all
    select 20260416223613483::bigint union all
    select 20260416223629048::bigint union all
    select 20260416223727489::bigint union all
    select 20260416220840601::bigint
)
select distinct run_id
from target_runs
order by run_id;


-- =========================================================
-- 1) KOLIK FIXTURES JE VE STAGING.api_football_fixtures
-- =========================================================
with target_runs as (
    select 20260416220840601::bigint as run_id union all
    select 20260416220857378::bigint union all
    select 20260416223527869::bigint union all
    select 20260416223613483::bigint union all
    select 20260416223629048::bigint union all
    select 20260416223727489::bigint
)
select
    f.run_id,
    count(*) as staging_rows,
    count(distinct f.fixture_id) as staging_distinct_fixture_ids,
    min(f.kickoff) as min_kickoff,
    max(f.kickoff) as max_kickoff
from staging.api_football_fixtures f
join target_runs r
  on r.run_id = f.run_id
group by f.run_id
order by f.run_id;


-- =========================================================
-- 2) NULL / PROBLÉMOVÁ DATA VE STAGING.api_football_fixtures
-- =========================================================
with target_runs as (
    select 20260416220840601::bigint as run_id union all
    select 20260416220857378::bigint union all
    select 20260416223527869::bigint union all
    select 20260416223613483::bigint union all
    select 20260416223629048::bigint union all
    select 20260416223727489::bigint
)
select
    f.run_id,
    count(*) as total_rows,
    count(*) filter (where f.fixture_id is null) as null_fixture_id,
    count(*) filter (where f.league_id is null) as null_league_id,
    count(*) filter (where f.home_team_id is null) as null_home_team_id,
    count(*) filter (where f.away_team_id is null) as null_away_team_id,
    count(*) filter (where f.kickoff is null) as null_kickoff,
    count(*) filter (where f.status is null) as null_status
from staging.api_football_fixtures f
join target_runs r
  on r.run_id = f.run_id
group by f.run_id
order by f.run_id;


-- =========================================================
-- 3) EXISTUJE UŽ TO V public.matches POD ext_match_id?
-- =========================================================
with target_runs as (
    select 20260416220840601::bigint as run_id union all
    select 20260416220857378::bigint union all
    select 20260416223527869::bigint union all
    select 20260416223613483::bigint union all
    select 20260416223629048::bigint union all
    select 20260416223727489::bigint
)
select
    f.run_id,
    count(distinct f.fixture_id) as staging_distinct,
    count(distinct m.ext_match_id) as matched_in_public_by_ext_match_id,
    count(distinct f.fixture_id) - count(distinct m.ext_match_id) as still_missing_by_ext_match_id
from staging.api_football_fixtures f
join target_runs r
  on r.run_id = f.run_id
left join public.matches m
  on m.ext_source = 'api_football'
 and m.ext_match_id = f.fixture_id::text
group by f.run_id
order by f.run_id;


-- =========================================================
-- 4) EXISTUJE STEJNÝ MATCH V public.matches
--    PODLE teams + kickoff ?
-- =========================================================
with target_runs as (
    select 20260416220840601::bigint as run_id union all
    select 20260416220857378::bigint union all
    select 20260416223527869::bigint union all
    select 20260416223613483::bigint union all
    select 20260416223629048::bigint union all
    select 20260416223727489::bigint
)
select
    f.run_id,
    count(*) as staging_rows,
    count(*) filter (where m_same.id is not null) as exists_same_match_identity,
    count(*) filter (where m_same.id is null) as missing_same_match_identity
from staging.api_football_fixtures f
join target_runs r
  on r.run_id = f.run_id
left join public.matches m_same
  on m_same.ext_source = 'api_football'
 and m_same.home_team_id = f.home_team_id
 and m_same.away_team_id = f.away_team_id
 and m_same.kickoff = (f.kickoff at time zone 'UTC')
group by f.run_id
order by f.run_id;


-- =========================================================
-- 5) DETAIL CHYBĚJÍCÍCH FIXTURES
--    = nejsou ani přes ext_match_id ani přes stejnou identitu
-- =========================================================
with target_runs as (
    select 20260416220840601::bigint as run_id union all
    select 20260416220857378::bigint union all
    select 20260416223527869::bigint union all
    select 20260416223613483::bigint union all
    select 20260416223629048::bigint union all
    select 20260416223727489::bigint
)
select
    f.run_id,
    f.league_id,
    f.season,
    f.fixture_id,
    f.kickoff,
    f.status,
    f.home_team_id,
    ht.name as home_team_name,
    f.away_team_id,
    at.name as away_team_name,
    case when m_ext.id is not null then 'FOUND_BY_EXT_MATCH_ID' else 'NOT_FOUND_BY_EXT_MATCH_ID' end as ext_match_check,
    case when m_same.id is not null then 'FOUND_BY_SAME_IDENTITY' else 'NOT_FOUND_BY_SAME_IDENTITY' end as identity_check
from staging.api_football_fixtures f
join target_runs r
  on r.run_id = f.run_id
left join public.teams ht
  on ht.id = f.home_team_id
left join public.teams at
  on at.id = f.away_team_id
left join public.matches m_ext
  on m_ext.ext_source = 'api_football'
 and m_ext.ext_match_id = f.fixture_id::text
left join public.matches m_same
  on m_same.ext_source = 'api_football'
 and m_same.home_team_id = f.home_team_id
 and m_same.away_team_id = f.away_team_id
 and m_same.kickoff = (f.kickoff at time zone 'UTC')
where m_ext.id is null
  and m_same.id is null
order by f.run_id, f.kickoff, ht.name, at.name;


-- =========================================================
-- 6) JSOU TO DUPLICITY VE STAGINGU?
-- =========================================================
with target_runs as (
    select 20260416220840601::bigint as run_id union all
    select 20260416220857378::bigint union all
    select 20260416223527869::bigint union all
    select 20260416223613483::bigint union all
    select 20260416223629048::bigint union all
    select 20260416223727489::bigint
)
select
    f.fixture_id,
    count(*) as cnt,
    string_agg(distinct f.run_id::text, ', ' order by f.run_id::text) as run_ids
from staging.api_football_fixtures f
join target_runs r
  on r.run_id = f.run_id
group by f.fixture_id
having count(*) > 1
order by cnt desc, f.fixture_id;


-- =========================================================
-- 7) JOB RUNS OKOLO PROBLÉMOVÉHO OKNA
-- =========================================================
select
    jr.id,
    jr.job_code,
    jr.status,
    jr.started_at,
    jr.finished_at,
    jr.message,
    jr.details
from ops.job_runs jr
where jr.started_at >= '2026-04-16 19:50:00+00'
order by jr.started_at, jr.id;


-- =========================================================
-- 8) JEN RYCHLÝ CHECK KICKOFF TYPŮ
-- =========================================================
select
    pg_typeof(f.kickoff) as staging_kickoff_type,
    pg_typeof(m.kickoff) as public_kickoff_type
from staging.api_football_fixtures f
cross join public.matches m
limit 1;