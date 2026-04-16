-- 1) vytvor canonical BK ligu, pokud jeste neexistuje
INSERT INTO public.leagues (
    sport_id,
    name,
    ext_source,
    ext_league_id
)
SELECT
    2,
    'Liga ACB',
    'api_sport_basketball',
    '117'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.leagues l
    WHERE l.ext_source = 'api_sport_basketball'
      AND l.ext_league_id = '117'
);

-- 2) dopln league_id do BK matches
UPDATE public.matches m
SET league_id = l.id
FROM public.leagues l
WHERE l.ext_source = 'api_sport_basketball'
  AND l.ext_league_id = '117'
  AND m.ext_source = 'api_sport'
  AND m.sport_id = 2
  AND m.league_id IS NULL;