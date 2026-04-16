-- 701_afb_readiness_audit.sql
-- AFB pipeline - prvni audit readiness
-- Spoustet v DBeaveru

-- 1) sport AFB v canonical sports
select *
from public.sports
where upper(code) in ('AFB', 'AMERICAN_FOOTBALL');

-- 2) existujici AFB leagues
select id, sport_id, name, country, ext_source, ext_league_id, theodds_key
from public.leagues
where upper(ext_source) like '%AMERICAN_FOOTBALL%'
   or upper(name) like '%NFL%'
order by id;

-- 3) provider map pro ligy
select *
from public.league_provider_map
where lower(provider) like '%american_football%'
order by league_id, provider_league_id;

-- 4) ingest targets pro AFB
select *
from ops.ingest_targets
where upper(sport_code) = 'AFB'
   or lower(provider) like '%american_football%'
order by provider, provider_league_id, season;

-- 5) league import plan
select *
from ops.league_import_plan
where upper(sport_code) = 'AFB'
   or lower(provider) like '%american_football%'
order by provider, provider_league_id, season;

-- 6) uz existujici AFB matches
select
    m.ext_source,
    m.sport_id,
    count(*) as matches_count,
    min(m.kickoff) as min_kickoff,
    max(m.kickoff) as max_kickoff
from public.matches m
where lower(coalesce(m.ext_source, '')) like '%american_football%'
group by m.ext_source, m.sport_id
order by matches_count desc;

-- 7) uz existujici AFB teams
select
    t.ext_source,
    count(*) as teams_count
from public.teams t
where lower(coalesce(t.ext_source, '')) like '%american_football%'
group by t.ext_source
order by teams_count desc;

-- 8) provider map tymu
select
    provider,
    count(*) as map_count
from public.team_provider_map
where lower(provider) like '%american_football%'
group by provider
order by provider;

-- 9) staging tabulky s AFB obsahem - pokud existuji generic zaznamy
select table_schema, table_name
from information_schema.tables
where table_schema in ('staging', 'public', 'ops')
  and (
      lower(table_name) like '%american_football%'
      or lower(table_name) like '%afb%'
  )
order by table_schema, table_name;

-- 10) posledni joby / runy souvisejici s AFB
select *
from ops.job_runs
where lower(job_code) like '%american_football%'
   or lower(message) like '%american_football%'
order by started_at desc
limit 50;

-- 11) api import runs
select *
from public.api_import_runs
where lower(source) like '%american_football%'
order by started_at desc
limit 50;