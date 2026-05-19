-- create_v_media_feed_by_player_v1.sql

CREATE OR REPLACE VIEW public.v_media_feed_by_player AS
SELECT
    apm.player_id,
    p.name AS player_name,
    p.team_id,
    a.id AS article_id,
    a.title,
    a.url,
    a.summary,
    a.thumbnail_url,
    a.video_url,
    a.is_video,
    a.content_type,
    a.published_at,
    a.article_quality_score,
    a.article_quality_reason,
    a.is_feed_eligible,
    cs.name AS source_name,
    cs.source_type,
    cs.is_official
FROM public.article_player_map apm
JOIN public.players p
    ON p.id = apm.player_id
JOIN public.articles a
    ON a.id = apm.article_id
LEFT JOIN public.content_sources cs
    ON cs.id = a.content_source_id
WHERE COALESCE(a.article_quality_score, 0) >= 70
ORDER BY
    a.published_at DESC NULLS LAST,
    a.article_quality_score DESC,
    a.id DESC;