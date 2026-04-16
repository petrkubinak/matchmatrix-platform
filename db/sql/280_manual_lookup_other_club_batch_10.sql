-- =====================================================================
-- 280_manual_lookup_other_club_batch_10.sql
-- Rucni lookup prvni davky OTHER_CLUB_CASES bez rizikoveho auto-match
-- =====================================================================

SELECT id, name
FROM public.teams
WHERE
       LOWER(name) LIKE '%real murcia%'
    OR LOWER(name) LIKE '%clyde%'
    OR LOWER(name) LIKE '%matsumoto%'
    OR LOWER(name) LIKE '%omiya%'
    OR LOWER(name) LIKE '%nara%'
    OR LOWER(name) LIKE '%kitakyushu%'
    OR LOWER(name) LIKE '%grulla%'
    OR LOWER(name) LIKE '%aschaffenburg%'
    OR LOWER(name) LIKE '%stranraer%'
    OR LOWER(name) LIKE '%stirling%'
ORDER BY name;