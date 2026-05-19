CREATE OR REPLACE VIEW public.v_homepage_media_feed_v1 AS
SELECT
    a.id AS article_id,
    a.title,
    a.slug,
    a.summary,
    a.url,
    a.author_name,
    a.published_at,
    a.created_at,
    COALESCE(a.published_at, a.created_at) AS display_published_at,
    a.language_code,
    a.content_type,

    cs.id AS content_source_id,
    cs.name AS source_name,
    cs.source_type,
    cs.base_url,
    cs.is_official,

    a.entity_count,
    a.quality_score,
    a.ai_relevance_score,
    a.playoff_related,

    CASE
        WHEN a.playoff_related = true THEN 25
        ELSE 0
    END AS playoff_boost,

    (
        COALESCE(a.ai_relevance_score, 0)
        + COALESCE(a.quality_score, 0)
        + CASE
            WHEN a.playoff_related = true THEN 25
            ELSE 0
          END
    ) AS feed_score

FROM public.articles a
JOIN public.content_sources cs
    ON cs.id = a.content_source_id
WHERE cs.is_active = true
  AND a.content_type = 'article';