-- 702_insert_public_leagues_hb_core.sql
-- Cíl:
-- Založit canonical HB leagues do public.leagues pro:
-- 131 Champions League
-- 145 EHF European League
-- 183 African Championship

WITH hb_sport AS (
    SELECT id AS sport_id
    FROM public.sports
    WHERE code = 'HB'
    LIMIT 1
),
src AS (
    SELECT *
    FROM (
        VALUES
            ('Champions League',     'api_handball', '131', NULL, 1, false, true),
            ('EHF European League',  'api_handball', '145', NULL, 1, false, true),
            ('African Championship', 'api_handball', '183', NULL, 2, false, true)
    ) AS t(
        name,
        ext_source,
        ext_league_id,
        country,
        tier,
        is_cup,
        is_international
    )
)
INSERT INTO public.leagues (
    sport_id,
    name,
    country,
    ext_source,
    ext_league_id,
    tier,
    is_cup,
    is_international,
    created_at,
    updated_at
)
SELECT
    hs.sport_id,
    s.name,
    s.country,
    s.ext_source,
    s.ext_league_id,
    s.tier,
    s.is_cup,
    s.is_international,
    NOW(),
    NOW()
FROM src s
CROSS JOIN hb_sport hs
WHERE NOT EXISTS (
    SELECT 1
    FROM public.leagues l
    WHERE l.ext_source = s.ext_source
      AND l.ext_league_id = s.ext_league_id
);

-- kontrola
SELECT
    l.id,
    l.name,
    l.ext_source,
    l.ext_league_id,
    l.tier,
    l.is_cup,
    l.is_international,
    sp.code AS sport_code
FROM public.leagues l
JOIN public.sports sp
  ON sp.id = l.sport_id
WHERE l.ext_source = 'api_handball'
  AND l.ext_league_id IN ('131','145','183')
ORDER BY l.ext_league_id;