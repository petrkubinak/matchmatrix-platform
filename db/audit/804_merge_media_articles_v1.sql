-- 804_merge_media_articles_v1.sql
-- MATCHMATRIX MEDIA ARTICLES – STAGING -> PUBLIC MERGE V1

BEGIN;

-- 1) content_sources
INSERT INTO public.content_sources (
    name,
    source_type,
    base_url,
    rss_url,
    language_code,
    country_code,
    is_official,
    is_active,
    notes
)
SELECT DISTINCT
    s.source_name,
    s.source_type,
    NULL,
    NULL,
    s.language_code,
    s.country_code,
    false,
    true,
    'Created from staging.stg_media_articles'
FROM staging.stg_media_articles s
WHERE s.parse_status IN ('pending', 'parsed')
ON CONFLICT (name, source_type)
DO UPDATE SET
    language_code = COALESCE(EXCLUDED.language_code, public.content_sources.language_code),
    country_code  = COALESCE(EXCLUDED.country_code, public.content_sources.country_code),
    updated_at    = now();

-- 2) articles
INSERT INTO public.articles (
    content_source_id,
    title,
    slug,
    summary,
    url,
    author_name,
    published_at,
    language_code,
    content_type,
    raw_html_path,
    raw_text,
    ai_summary
)
SELECT
    cs.id,
    s.title,
    lower(regexp_replace(regexp_replace(s.title, '[^a-zA-Z0-9]+', '-', 'g'), '(^-|-$)', '', 'g')) AS slug,
    s.summary,
    s.url,
    s.author_name,
    s.published_at,
    s.language_code,
    'article',
    NULL,
    s.raw_text,
    NULL
FROM staging.stg_media_articles s
JOIN public.content_sources cs
  ON cs.name = s.source_name
 AND cs.source_type = s.source_type
WHERE s.parse_status IN ('pending', 'parsed')
ON CONFLICT (content_source_id, url)
DO UPDATE SET
    title         = EXCLUDED.title,
    summary       = EXCLUDED.summary,
    author_name   = EXCLUDED.author_name,
    published_at  = EXCLUDED.published_at,
    language_code = EXCLUDED.language_code,
    raw_text      = EXCLUDED.raw_text,
    updated_at    = now();

-- 3) staging status
UPDATE staging.stg_media_articles
SET
    parse_status = 'merged',
    parse_message = 'Merged to public.articles',
    updated_at = now()
WHERE parse_status IN ('pending', 'parsed');

-- 4) kontrola
SELECT
    'content_sources' AS table_name,
    COUNT(*) AS rows_count
FROM public.content_sources

UNION ALL

SELECT
    'articles' AS table_name,
    COUNT(*) AS rows_count
FROM public.articles

UNION ALL

SELECT
    'stg_media_articles_merged' AS table_name,
    COUNT(*) AS rows_count
FROM staging.stg_media_articles
WHERE parse_status = 'merged';

COMMIT;