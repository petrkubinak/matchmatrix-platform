-- create_v_media_feed_unmatched_articles_v1.sql
-- View pro kvalitní články, které zatím nemají article_match_map.
-- Použitelné pro homepage / team / league feedy, než bude doplněna match coverage.

CREATE OR REPLACE VIEW public.v_media_feed_unmatched_articles AS
SELECT
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
FROM public.articles a
LEFT JOIN public.content_sources cs
    ON cs.id = a.content_source_id
LEFT JOIN public.article_match_map amm
    ON amm.article_id = a.id
WHERE amm.article_id IS NULL
  AND COALESCE(a.article_quality_score, 0) >= 70
ORDER BY
    a.published_at DESC NULLS LAST,
    a.article_quality_score DESC,
    a.id DESC;