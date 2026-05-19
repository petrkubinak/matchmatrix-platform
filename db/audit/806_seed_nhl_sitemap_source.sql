-- 806_seed_nhl_sitemap_source.sql
-- NHL sitemap source seed

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
VALUES (
    'NHL',
    'sitemap',
    'https://www.nhl.com',
    'https://www.nhl.com/sitemap.xml',
    'en',
    'US',
    true,
    true,
    'Primary NHL sitemap/news source for MEDIA layer'
)
ON CONFLICT (name, source_type)
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    rss_url = EXCLUDED.rss_url,
    is_active = true,
    updated_at = now();

-- kontrola
SELECT
    id,
    name,
    source_type,
    base_url,
    rss_url,
    is_active
FROM public.content_sources
WHERE name = 'NHL'
ORDER BY id;