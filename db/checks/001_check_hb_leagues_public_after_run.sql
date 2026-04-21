-- 001_check_hb_leagues_public_after_run.sql
-- Kontrola, jestli poslední HB leagues run propsal více soutěží do public vrstvy

-- 1) public.leagues pro api_handball
SELECT
    l.id,
    l.name,
    l.country,
    l.ext_source,
    l.ext_league_id
FROM public.leagues l
WHERE l.ext_source = 'api_handball'
ORDER BY l.name;

-- 2) souhrnný počet
SELECT
    COUNT(*) AS public_hb_leagues_count
FROM public.leagues l
WHERE l.ext_source = 'api_handball';

-- 3) provider map pro HB
SELECT
    lpm.league_id,
    l.name AS league_name,
    lpm.provider,
    lpm.provider_league_id,
    lpm.created_at,
    lpm.updated_at
FROM public.league_provider_map lpm
LEFT JOIN public.leagues l
       ON l.id = lpm.league_id
WHERE lpm.provider = 'api_handball'
ORDER BY lpm.provider_league_id;

-- 4) souhrnný počet provider map
SELECT
    COUNT(*) AS hb_league_provider_map_count
FROM public.league_provider_map lpm
WHERE lpm.provider = 'api_handball';

-- 5) porovnání proti stagingu pro season 2024
SELECT
    spl.provider,
    spl.sport_code,
    spl.season,
    COUNT(*) AS staging_hb_leagues_2024
FROM staging.stg_provider_leagues spl
WHERE spl.provider = 'api_handball'
  AND spl.sport_code = 'HB'
  AND spl.season = '2024'
GROUP BY
    spl.provider,
    spl.sport_code,
    spl.season;

-- 6) kontrola active flagu ve stagingu
SELECT
    spl.is_active,
    COUNT(*) AS cnt
FROM staging.stg_provider_leagues spl
WHERE spl.provider = 'api_handball'
  AND spl.sport_code = 'HB'
  AND spl.season = '2024'
GROUP BY spl.is_active
ORDER BY spl.is_active;