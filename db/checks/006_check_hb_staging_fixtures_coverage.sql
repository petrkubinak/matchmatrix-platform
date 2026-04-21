-- 006_check_hb_staging_fixtures_coverage.sql

-- 1) kolik HB fixtures je ve stagingu celkem
SELECT
    COUNT(*) AS hb_staging_fixtures_count
FROM staging.stg_provider_fixtures
WHERE provider = 'api_handball';

-- 2) staging fixtures po external league id
SELECT
    sf.external_league_id,
    COUNT(*) AS staging_fixtures_count
FROM staging.stg_provider_fixtures sf
WHERE sf.provider = 'api_handball'
GROUP BY sf.external_league_id
ORDER BY staging_fixtures_count DESC, sf.external_league_id;

-- 3) spojení staging fixtures -> public leagues podle league_provider_map
SELECT
    l.name,
    l.ext_league_id,
    COUNT(*) AS staging_fixtures_count
FROM staging.stg_provider_fixtures sf
JOIN public.league_provider_map lpm
  ON lpm.provider = sf.provider
 AND lpm.provider_league_id = sf.external_league_id
JOIN public.leagues l
  ON l.id = lpm.league_id
WHERE sf.provider = 'api_handball'
GROUP BY l.name, l.ext_league_id
ORDER BY staging_fixtures_count DESC, l.name;

-- 4) které HB ligy už existují v public.leagues, ale nemají žádný staging fixture
SELECT
    l.id,
    l.name,
    l.ext_league_id
FROM public.leagues l
LEFT JOIN public.league_provider_map lpm
  ON lpm.league_id = l.id
 AND lpm.provider = 'api_handball'
LEFT JOIN staging.stg_provider_fixtures sf
  ON sf.provider = lpm.provider
 AND sf.external_league_id = lpm.provider_league_id
WHERE l.ext_source = 'api_handball'
GROUP BY l.id, l.name, l.ext_league_id
HAVING COUNT(sf.id) = 0
ORDER BY l.name;