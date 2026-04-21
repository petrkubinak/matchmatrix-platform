-- =====================================================================
-- 281_other_club_cases_presence_check.sql
-- Ověření, které OTHER_CLUB_CASES vůbec existují v public.teams
-- =====================================================================

WITH club_queue AS (
    SELECT *
    FROM (
        VALUES
        ('5275','Real Murcia'),
        ('6762','Clyde'),
        ('304','Matsumoto Yamaga'),
        ('313','Omiya Ardija'),
        ('7135','Nara Club'),
        ('805','Kitakyushu'),
        ('4321','Grulla Morioka'),
        ('9336','Viktoria Aschaffenburg'),
        ('6785','Stranraer'),
        ('4669','Stirling Albion')
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