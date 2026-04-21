-- 733_audit_hb_active_leagues_2024.sql
-- Cíl:
-- 1) potvrdit, kolik HB leagues 2024 máme ve stagingu
-- 2) kolik z nich je is_active = false
-- 3) které 2024 HB ligy chybí v public.leagues

-- 1) souhrn HB leagues 2024 ve stagingu podle is_active
SELECT
    season,
    is_active,
    COUNT(*) AS row_count,
    COUNT(DISTINCT external_league_id) AS distinct_leagues
FROM staging.stg_provider_leagues
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND season = '2024'
GROUP BY season, is_active
ORDER BY season, is_active;

-- 2) detail HB leagues 2024 ve stagingu
SELECT
    external_league_id,
    league_name,
    country_name,
    season,
    is_active,
    raw_payload_id,
    created_at
FROM staging.stg_provider_leagues
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND season = '2024'
ORDER BY country_name, league_name, external_league_id;

-- 3) HB leagues 2024, které jsou ve stagingu, ale nejsou v public.leagues
SELECT
    spl.external_league_id,
    spl.league_name,
    spl.country_name,
    spl.season,
    spl.is_active
FROM staging.stg_provider_leagues spl
LEFT JOIN public.leagues pl
    ON pl.ext_source = 'api_handball'
   AND pl.ext_league_id = spl.external_league_id
WHERE spl.provider = 'api_handball'
  AND spl.sport_code = 'HB'
  AND spl.season = '2024'
  AND pl.id IS NULL
ORDER BY spl.country_name, spl.league_name, spl.external_league_id;

-- 4) HB leagues 2024, které už v public.leagues jsou
SELECT
    pl.id,
    pl.ext_league_id,
    pl.name,
    pl.country,
    pl.ext_source
FROM public.leagues pl
WHERE pl.ext_source = 'api_handball'
ORDER BY pl.ext_league_id;