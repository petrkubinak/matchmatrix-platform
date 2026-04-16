-- =====================================================================
-- 284_insert_missing_canonical_clubs_batch_1.sql
-- Vlozeni prvni davky chybejicich canonical klubu do public.teams
-- =====================================================================

INSERT INTO public.teams (
    name,
    ext_source,
    ext_team_id,
    created_at,
    updated_at,
    logo_url
)
SELECT
    v.team_name,
    'api_football_missing_canonical',
    v.external_team_id,
    NOW(),
    NOW(),
    NULL
FROM (
    VALUES
        ('6762','Clyde'),
        ('4321','Grulla Morioka'),
        ('805','Kitakyushu'),
        ('304','Matsumoto Yamaga'),
        ('7135','Nara Club'),
        ('313','Omiya Ardija'),
        ('4669','Stirling Albion'),
        ('6785','Stranraer'),
        ('9336','Viktoria Aschaffenburg')
) AS v(external_team_id, team_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams t
    WHERE LOWER(BTRIM(t.name)) = LOWER(BTRIM(v.team_name))
);