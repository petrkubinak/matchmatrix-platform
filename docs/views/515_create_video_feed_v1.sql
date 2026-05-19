CREATE OR REPLACE VIEW public.v_video_feed_v1 AS
SELECT
    article_id,
    sport_code,
    source_name,
    title,
    summary,
    url,
    display_published_at,
    feed_score,
    playoff_related,
    entity_count
FROM public.v_homepage_media_feed_v2
WHERE content_type = 'video'
ORDER BY
    feed_score DESC,
    display_published_at DESC;