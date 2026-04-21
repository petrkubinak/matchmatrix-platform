-- 716_check_hb_leagues_after_first_run.sql
-- Účel:
-- Ověřit, zda první HB leagues run skutečně zapsal data.

-- =========================================================
-- A) poslední HB job_runs z unified ingest
-- =========================================================
select
    id,
    status,
    started_at,
    finished_at,
    params,
    details
from ops.job_runs
where upper(coalesce(params::text, '')) like '%API_HANDBALL%'
   or upper(coalesce(details::text, '')) like '%API_HANDBALL%'
   or upper(coalesce(params::text, '')) like '%HANDBALL%'
   or upper(coalesce(details::text, '')) like '%HANDBALL%'
order by started_at desc
limit 10;

-- =========================================================
-- B) staging.stg_provider_leagues pro HB / api_handball
-- =========================================================
select
    count(*) as hb_stg_provider_leagues_count
from staging.stg_provider_leagues
where upper(coalesce(provider, '')) = 'API_HANDBALL'
   or upper(coalesce(sport_code, '')) = 'HB';

-- =========================================================
-- C) poslední HB staging leagues řádky
-- =========================================================
select *
from staging.stg_provider_leagues
where upper(coalesce(provider, '')) = 'API_HANDBALL'
   or upper(coalesce(sport_code, '')) = 'HB'
order by coalesce(updated_at, created_at) desc nulls last
limit 20;

-- =========================================================
-- D) public.leagues napojené na api_handball / HB
-- =========================================================
select
    count(*) as hb_public_leagues_count
from public.league_provider_map
where upper(coalesce(provider, '')) = 'API_HANDBALL';

-- =========================================================
-- E) detail public.league_provider_map pro api_handball
-- =========================================================
select *
from public.league_provider_map
where upper(coalesce(provider, '')) = 'API_HANDBALL'
order by id desc
limit 20;