-- =====================================================================
-- 291_insert_missing_canonical_clubs_batch_6.sql
-- Vlozeni seste davky chybejicich canonical klubu do public.teams
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
        ('6781','Spartans'),
        ('1239','Staphorst'),
        ('4669','Stirling Albion'),
        ('6785','Stranraer'),
        ('10409','Tegevajaro Miyazaki'),
        ('9336','Viktoria Aschaffenburg'),
        ('21644','XerxesDZB (Zat)'),
        ('16381','Xorazm'),
        ('6652','YF Juventus'),
        ('4327','YSCC')
) AS v(external_team_id, team_name)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.teams t
    WHERE LOWER(BTRIM(t.name)) = LOWER(BTRIM(v.team_name))
);