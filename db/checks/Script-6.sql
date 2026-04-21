-- 716_check_hb_leagues_after_first_run_fix.sql
-- Účel:
-- Ověřit, zda první HB leagues run skutečně zapsal data.

-- =========================================================
-- A) poslední HB job_runs
-- =========================================================
select
    id,
    job_code,
    status,
    started_at,
    finished_at,
    params,
    message,
    details
from ops.job_runs
where upper(coalesce(params::text, '')) like '%API_HANDBALL%'
   or upper(coalesce(details::text, '')) like '%API_HANDBALL%'
   or upper(coalesce(params::text, '')) like '%HANDBALL%'
   or upper(coalesce(details::text, '')) like '%HANDBALL%'
order by started_at desc
limit 10;

-- =========================================================
-- B) staging.stg_provider_leagues count pro HB
-- =========================================================
select
    count(*) as hb_stg_provider_leagues_count
from staging.stg_provider_leagues
where upper(coalesce(provider, '')) = 'API_HANDBALL'
   or upper(coalesce(sport_code, '')) = 'HB';

-- =========================================================
-- C) poslední HB staging leagues řádky
-- =========================================================
select
    id,
    provider,
    sport_code,
    external_league_id,
    league_name,
    country_name,
    season,
    raw_payload_id,
    is_active,
    created_at,
    updated_at
from staging.stg_provider_leagues
where upper(coalesce(provider, '')) = 'API_HANDBALL'
   or upper(coalesce(sport_code, '')) = 'HB'
order by coalesce(updated_at, created_at) desc nulls last
limit 20;

-- =========================================================
-- D) public.league_provider_map count pro api_handball
-- =========================================================
select
    count(*) as hb_public_league_provider_map_count
from public.league_provider_map
where upper(coalesce(provider, '')) = 'API_HANDBALL';

-- =========================================================
-- E) detail public.league_provider_map pro api_handball
-- =========================================================
select
    league_id,
    provider,
    provider_league_id,
    created_at,
    updated_at
from public.league_provider_map
where upper(coalesce(provider, '')) = 'API_HANDBALL'
order by coalesce(updated_at, created_at) desc nulls last, league_id desc
limit 20;