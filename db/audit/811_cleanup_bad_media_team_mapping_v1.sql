-- 811_cleanup_bad_media_team_mapping_v1.sql
-- MEDIA ARTICLE TEAM MAP CLEANUP V1
-- Čistí špatné automatické mapování z heuristiky podle URL.

BEGIN;

DELETE FROM public.article_team_map
WHERE article_id IN (
    SELECT id
    FROM public.articles
    WHERE url ILIKE '%nhl.com/news%'
);

-- kontrola
SELECT
    COUNT(*) AS article_team_maps_after_cleanup
FROM public.article_team_map;

COMMIT;