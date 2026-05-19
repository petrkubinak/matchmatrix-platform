CREATE OR REPLACE VIEW public.v_media_feed_latest AS
SELECT
    a.id,
    a.title,
    a.summary,
    a.url,
    a.thumbnail_url,
    a.video_url,
    a.is_video,
    a.content_type,
    a.article_quality_score,
    a.article_quality_reason,
    a.published_at,
    a.created_at,

    cs.name AS source_name,
    cs.source_type,
    cs.language_code,
    cs.country_code,
    cs.is_official

FROM public.articles a
LEFT JOIN public.content_sources cs
       ON cs.id = a.content_source_id

WHERE
    a.article_quality_score >= 70
    AND (
        (cs.name = 'NBA' AND a.url LIKE 'https://www.nba.com/%')
        OR (cs.name = 'NHL' AND a.url LIKE 'https://www.nhl.com/%')
        OR cs.name NOT IN ('NBA', 'NHL')
    )

ORDER BY
    COALESCE(a.published_at, a.created_at) DESC;