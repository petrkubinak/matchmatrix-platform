CREATE OR REPLACE VIEW public.v_homepage_top_headlines_v1 AS
SELECT
    *
FROM public.v_homepage_media_feed_v2
WHERE feed_score >= 100
ORDER BY
    feed_score DESC,
    display_published_at DESC;