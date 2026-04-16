-- =====================================================================
-- 289_insert_missing_canonical_clubs_batch_4.sql
-- Vlozeni ctvrte davky chybejicich canonical klubu do public.teams
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
        ('1020','Inter Zapresic'),
        ('21421','Kampong'),
        ('805','Kitakyushu'),
        ('14504','Kreuzlingen'),
        ('6628','Lancy'),
        ('304','Matsumoto Yamaga'),
        ('6630','Meyrin'),
        ('7135','Nara Club'),
        ('1241','OJC Rosmalen'),
        ('313','Omiya Ardija')
) AS v(external_team_id, team_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams t
    WHERE LOWER(BTRIM(t.name)) = LOWER(BTRIM(v.team_name))
);