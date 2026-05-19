-- 827_seed_uefa_official_site_source.sql
-- UEFA official_site source seed

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
    'UEFA',
    'official_site',
    'https://www.uefa.com/news-media/news/',
    NULL,
    'en',
    'EU',
    true,
    true,
    'Primary UEFA official news source for MEDIA layer'
)
ON CONFLICT (name, source_type)
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    is_active = true,
    updated_at = now();

-- kontrola
SELECT
    id,
    name,
    source_type,
    base_url,
    is_active
FROM public.content_sources
WHERE name = 'UEFA'
ORDER BY id;