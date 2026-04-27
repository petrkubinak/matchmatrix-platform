SELECT
    id,
    sport_id,
    name,
    country,
    ext_source,
    ext_league_id,
    is_active
FROM public.leagues
WHERE ext_source = 'api_cricket'
   OR (sport_id = 14 AND ext_league_id IN (
        '10532','10559','10565','10576','11595','11606','11612','11630',
        '11641','11733','11814','11825','11858','11876','11883','11902',
        '11913','11924','11935','11946','11957','11968','11991','11997',
        '12004','12012','12034','12052','12063','12070','12081','7572'
   ))
ORDER BY ext_league_id;

-- 743_fix_ck_leagues_sport_id.sql

UPDATE public.leagues
SET
    sport_id = 14,
    updated_at = now()
WHERE ext_source = 'api_cricket'

SELECT
    id,
    sport_id,
    name,
    ext_source,
    ext_league_id,
    is_active
FROM public.leagues
WHERE ext_source = 'api_cricket'
ORDER BY ext_league_id;
  AND sport_id <> 14;