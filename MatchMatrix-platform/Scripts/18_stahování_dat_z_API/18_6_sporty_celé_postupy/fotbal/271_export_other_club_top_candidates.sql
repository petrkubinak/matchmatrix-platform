-- =====================================================================
-- 271_export_other_club_top_candidates.sql
-- Jen top klubove pripady k manualnimu mapovani
-- =====================================================================

SELECT *
FROM (
    SELECT
        external_team_id,
        team_name
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
    ) AS t(external_team_id, team_name)
) x;