SELECT *
FROM mm_value_bets
ORDER BY created_at DESC
LIMIT 20;

SELECT
COUNT(*)
FROM mm_value_bets;

SELECT *
FROM vw_ticket_candidate_matches
ORDER BY edge_home DESC
LIMIT 30;

SELECT *
FROM public.api_import_runs
ORDER BY id DESC
LIMIT 10;

SELECT *
FROM public.api_raw_payloads
ORDER BY id DESC
LIMIT 10;

SELECT
source,
endpoint,
count(*)
FROM api_raw_payloads
GROUP BY 1,2;

SELECT COUNT(*) FROM public.leagues WHERE ext_source = 'api_sport';

SELECT id, sport_id, name, country, ext_source, ext_league_id
FROM public.leagues
WHERE ext_source = 'api_sport'
ORDER BY id DESC
LIMIT 20;

SELECT id, code, name
FROM public.sports
ORDER BY id;

SELECT
    s.code,
    s.name,
    COUNT(*) AS leagues_count
FROM public.leagues l
JOIN public.sports s
    ON s.id = l.sport_id
WHERE l.ext_source = 'api_sport'
GROUP BY s.code, s.name
ORDER BY s.code;

SELECT id, sport_id, name, country, ext_source, ext_league_id
FROM public.leagues
WHERE ext_source = 'api_sport'
ORDER BY id DESC
LIMIT 30;

SELECT
    s.code,
    s.name,
    COUNT(*) AS leagues_count
FROM public.leagues l
JOIN public.sports s
    ON s.id = l.sport_id
WHERE l.ext_source = 'api_sport'
GROUP BY s.code, s.name
ORDER BY s.code;

SELECT COUNT(*)
FROM public.leagues
WHERE ext_source='api_sport'
AND sport_id = 2;