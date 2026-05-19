-- create_v_video_feed_v2.sql
-- Čistý VIDEO FEED postavený přímo nad v_media_feed_videos.
-- Nepoužívá homepage feed mapping, který vracel špatné sport/source kombinace.

CREATE OR REPLACE VIEW public.v_video_feed_v2 AS
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
    a.article_quality_score DESC,
    a.published_at DESC NULLS LAST,
    a.id DESC;