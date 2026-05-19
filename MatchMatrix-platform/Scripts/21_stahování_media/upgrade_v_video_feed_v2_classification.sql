-- ============================================
-- CO TO DĚLÁ:
-- Přestaví VIDEO FEED view s novým sloupcem:
-- video_content_type
--
-- REAL_VIDEO
-- VIDEO_ARTICLE
--
-- KAM TO VEDE:
-- public.v_video_feed_v2
--
-- K ČEMU TO BUDE:
-- Frontend pozná:
-- - skutečné video
-- - nebo jen recap/live článek
--
-- VYUŽITÍ NA WEBU/APLIKACI:
--
-- REAL_VIDEO:
-- ▶ přehrávače
-- ▶ highlights
-- ▶ autoplay feed
--
-- VIDEO_ARTICLE:
-- 📰 recap
-- 📰 playoff stories
-- 📰 live updates
-- ============================================


DROP VIEW IF EXISTS public.v_video_feed_v2;


CREATE VIEW public.v_video_feed_v2 AS
SELECT
    a.id AS article_id,

    CASE
        WHEN lower(cs.name) LIKE '%nba%' THEN 'BK'
        WHEN lower(cs.name) LIKE '%nhl%' THEN 'HK'
        WHEN lower(cs.name) LIKE '%premier league%' THEN 'FB'
        WHEN lower(cs.name) LIKE '%laliga%' THEN 'FB'
        WHEN lower(cs.name) LIKE '%bundesliga%' THEN 'FB'
        WHEN lower(cs.name) LIKE '%uefa%' THEN 'FB'
        WHEN lower(cs.name) LIKE '%fifa%' THEN 'FB'
        ELSE NULL
    END AS sport_code,

    cs.name AS source_name,
    cs.source_type,

    a.title,
    a.summary,
    a.url,

    a.thumbnail_url,
    a.video_url,

    a.is_video,
    a.content_type,

    CASE
        WHEN a.video_url IS NOT NULL
        THEN 'REAL_VIDEO'
        ELSE 'VIDEO_ARTICLE'
    END AS video_content_type,

    a.published_at AS display_published_at,

    a.article_quality_score AS feed_score,

    a.playoff_related,
    a.entity_count,

    a.article_quality_reason

FROM public.articles a

LEFT JOIN public.content_sources cs
    ON cs.id = a.content_source_id

WHERE a.is_video = true
  AND COALESCE(a.article_quality_score, 0) >= 70

ORDER BY
    CASE
        WHEN a.video_url IS NOT NULL THEN 1
        ELSE 2
    END,
    a.article_quality_score DESC,
    a.published_at DESC NULLS LAST,
    a.id DESC;



-- ============================================
-- KONTROLA
-- ============================================

SELECT
    video_content_type,
    COUNT(*)
FROM public.v_video_feed_v2
GROUP BY video_content_type
ORDER BY video_content_type;