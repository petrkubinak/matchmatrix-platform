CREATE OR REPLACE VIEW public.v_media_feed_videos AS
SELECT *
FROM public.v_media_feed_latest
WHERE is_video = true
ORDER BY COALESCE(published_at, created_at) DESC;