-- =====================================================================
-- 282_export_missing_canonical_clubs_from_other_cases.sql
-- Fronta chybejicich canonical klubu pro public.teams
-- =====================================================================

WITH club_queue AS (
    SELECT *
    FROM (
        VALUES
        ('6762','Clyde'),
        ('4321','Grulla Morioka'),
        ('805','Kitakyushu'),
        ('304','Matsumoto Yamaga'),
        ('7135','Nara Club'),
        ('313','Omiya Ardija'),
        ('5275','Real Murcia'),
        ('4669','Stirling Albion'),
        ('6785','Stranraer'),
        ('9336','Viktoria Aschaffenburg')
    ) AS v(external_team_id, team_name)
)
SELECT
    q.external_team_id,
    q.team_name,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM public.teams t
            WHERE LOWER(t.name) = LOWER(q.team_name)
        ) THEN 'EXACT_IN_PUBLIC_TEAMS'
        WHEN EXISTS (
            SELECT 1
            FROM public.teams t
            WHERE LOWER(t.name) LIKE '%' || LOWER(q.team_name) || '%'
        ) THEN 'ONLY_LOOSE_MATCH_IN_PUBLIC_TEAMS'
        ELSE 'NOT_IN_PUBLIC_TEAMS'
    END AS presence_status
FROM club_queue q
ORDER BY q.team_name;