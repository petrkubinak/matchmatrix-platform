-- 734_activate_hb_2024_leagues_safe.sql
-- Cíl:
-- Bezpecne aktivovat HB leagues pro sezonu 2024 ve stagingu,
-- aby se mohly propsat do public.leagues a navazne do planneru.

-- 1) kontrola pred zmenou
SELECT
    external_league_id,
    league_name,
    country_name,
    season,
    is_active
FROM staging.stg_provider_leagues
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND season = '2024'
ORDER BY country_name, league_name, external_league_id;

-- 2) aktivace vsech HB leagues pro 2024
UPDATE staging.stg_provider_leagues
SET is_active = true,
    updated_at = NOW()
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND season = '2024'
  AND COALESCE(is_active, false) = false;

-- 3) kontrola po zmene
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

-- 4) detail po zmene
SELECT
    external_league_id,
    league_name,
    country_name,
    season,
    is_active
FROM staging.stg_provider_leagues
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND season = '2024'
ORDER BY country_name, league_name, external_league_id;