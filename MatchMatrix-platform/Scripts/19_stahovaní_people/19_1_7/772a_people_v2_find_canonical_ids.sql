SELECT
    l.id AS canonical_league_id,
    l.sport_id,
    l.name,
    l.country,
    l.ext_source,
    l.ext_league_id
FROM public.leagues l
WHERE
    (l.ext_source = 'api_football' AND l.ext_league_id = '39')
    OR
    (l.ext_source = 'api_american_football' AND l.ext_league_id = '1')
ORDER BY l.ext_source, l.ext_league_id;