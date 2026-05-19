-- 903_add_sitemap_source_type_v1.sql
-- MEDIA / CONTENT SOURCES
-- přidání sitemap source_type

ALTER TABLE public.content_sources
DROP CONSTRAINT IF EXISTS chk_content_sources_source_type;

ALTER TABLE public.content_sources
ADD CONSTRAINT chk_content_sources_source_type
CHECK (
    source_type IN (
        'rss',
        'news_api',
        'official_site',
        'youtube',
        'video_api',
        'social',
        'manual',
        'scraper',
        'partner_api',
        'sitemap'
    )
);