-- 731_audit_hb_leagues_parse_filter.sql
-- Cíl: najít, kde se HB leagues scope ořezává mezi RAW -> public.leagues

-- 1) kolik distinct ext_league_id je dnes v public.leagues pro api_handball
SELECT
    COUNT(DISTINCT l.ext_league_id) AS public_handball_leagues_distinct
FROM public.leagues l
WHERE l.ext_source = 'api_handball';

-- 2) které HB leagues už jsou v public.leagues
SELECT
    l.ext_league_id,
    l.name,
    l.country,
    l.created_at,
    l.updated_at
FROM public.leagues l
WHERE l.ext_source = 'api_handball'
ORDER BY l.ext_league_id;

-- 3) které HB league IDs už mají matches v public.matches
SELECT
    l.ext_league_id,
    l.name,
    COUNT(*) AS matches_cnt
FROM public.matches m
JOIN public.leagues l
  ON l.id = m.league_id
WHERE m.ext_source = 'api_handball'
GROUP BY l.ext_league_id, l.name
ORDER BY matches_cnt DESC, l.ext_league_id;

-- 4) zkontroluj, jestli ve staging.stg_provider_leagues je víc HB lig než v public.leagues
SELECT
    spl.provider,
    spl.sport_code,
    COUNT(*) AS rows_cnt,
    COUNT(DISTINCT spl.provider_league_id) AS distinct_provider_league_ids
FROM staging.stg_provider_leagues spl
WHERE spl.provider = 'api_handball'
   OR spl.sport_code IN ('HB', 'handball')
GROUP BY spl.provider, spl.sport_code;

-- 5) detail HB leagues ve staging.stg_provider_leagues
SELECT
    spl.provider,
    spl.sport_code,
    spl.provider_league_id,
    spl.name,
    spl.country,
    spl.season,
    spl.created_at,
    spl.updated_at
FROM staging.stg_provider_leagues spl
WHERE spl.provider = 'api_handball'
   OR spl.sport_code IN ('HB', 'handball')
ORDER BY spl.provider_league_id, spl.season;

-- 6) porovnani staging vs public
SELECT
    spl.provider_league_id,
    spl.name AS staging_name,
    spl.country AS staging_country,
    CASE
        WHEN pl.id IS NULL THEN 'MISSING_IN_PUBLIC'
        ELSE 'PRESENT_IN_PUBLIC'
    END AS public_state,
    pl.id AS public_league_id,
    pl.name AS public_name
FROM staging.stg_provider_leagues spl
LEFT JOIN public.leagues pl
    ON pl.ext_source = 'api_handball'
   AND pl.ext_league_id = spl.provider_league_id
WHERE spl.provider = 'api_handball'
   OR spl.sport_code IN ('HB', 'handball')
ORDER BY public_state DESC, spl.provider_league_id;