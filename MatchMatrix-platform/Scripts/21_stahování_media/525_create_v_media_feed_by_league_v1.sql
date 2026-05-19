CREATE OR REPLACE VIEW public.v_media_feed_by_league AS
SELECT
    l.id AS league_id,
    l.name AS league_name,
    l.country AS league_country,

    a.id AS article_id,
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

FROM public.article_league_map alm
JOIN public.leagues l
    ON l.id = alm.league_id
JOIN public.articles a
    ON a.id = alm.article_id
LEFT JOIN public.content_sources cs
    ON cs.id = a.content_source_id

WHERE
    a.article_quality_score >= 70

ORDER BY
    l.name,
    COALESCE(a.published_at, a.created_at) DESC;