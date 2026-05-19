-- check_video_views_definition_v1.sql
-- Audit definic video feed views.

SELECT
    table_name,
    view_definition
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name IN (
      'v_media_feed_videos',
      'v_video_feed_v1'
  );


-- Ukázka dat z views
SELECT *
FROM public.v_media_feed_videos
LIMIT 20;


SELECT *
FROM public.v_video_feed_v1
LIMIT 20;