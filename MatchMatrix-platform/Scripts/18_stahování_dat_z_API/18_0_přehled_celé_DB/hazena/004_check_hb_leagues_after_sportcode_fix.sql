SELECT COUNT(*) AS public_hb_leagues_count
FROM public.leagues
WHERE ext_source = 'api_handball';

SELECT COUNT(*) AS hb_league_provider_map_count
FROM public.league_provider_map
WHERE provider = 'api_handball';

SELECT
    id,
    name,
    country,
    ext_source,
    ext_league_id
FROM public.leagues
WHERE ext_source = 'api_handball'
ORDER BY ext_league_id::int;
