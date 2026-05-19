CREATE OR REPLACE VIEW public.v_media_feed_by_team AS
SELECT
    t.id AS team_id,
    t.name AS team_name,

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

FROM public.article_team_map atm
JOIN public.teams t
    ON t.id = atm.team_id
JOIN public.articles a
    ON a.id = atm.article_id
LEFT JOIN public.content_sources cs
    ON cs.id = a.content_source_id

WHERE
    a.article_quality_score >= 70

ORDER BY
    t.name,
    COALESCE(a.published_at, a.created_at) DESC;