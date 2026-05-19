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

    -- DOMAIN SANITY FILTER
    AND (
        (cs.name = 'NBA' AND a.url LIKE 'https://www.nba.com/%')
        OR (cs.name = 'NHL' AND a.url LIKE 'https://www.nhl.com/%')
        OR cs.name NOT IN ('NBA', 'NHL')
    )

    -- HOMEPAGE / ROOT NEWS EXCLUSION
    AND a.url NOT IN (
        'https://www.nhl.com/news',
        'https://www.nba.com/news',
        'https://www.laliga.com/en-GB/news',
        'https://www.bundesliga.com/en/bundesliga/news',
        'https://www.uefa.com/news-media/',
        'https://www.uefa.com/news-media/news/'
    )

    -- CATEGORY / ARCHIVE / HUB EXCLUSION
    AND a.url NOT LIKE '%/category/%'
    AND a.url NOT LIKE '%/topic/%'
    AND a.url NOT LIKE '%/topics/%'
    AND a.url NOT LIKE '%/tag/%'
    AND a.url NOT LIKE '%/tags/%'
    AND a.url NOT LIKE '%writers-archive%'
    AND a.url NOT LIKE '%key-dates%'
    AND a.url NOT LIKE '%nba-guide%'

ORDER BY
    COALESCE(a.published_at, a.created_at) DESC;