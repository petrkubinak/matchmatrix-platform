-- =====================================================================
-- 279_preview_other_club_matches_like.sql
-- Najdi realne canonical nazvy pro OTHER_CLUB_CASES batch
-- =====================================================================

SELECT
    v.external_team_id,
    v.team_name AS staging_name,
    t.id AS team_id,
    t.name AS canonical_name
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

JOIN public.teams t
  ON LOWER(t.name) LIKE '%' || LOWER(v.team_name) || '%'

ORDER BY v.team_name, t.name;