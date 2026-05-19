-- 808_seed_nhl_official_site_source.sql
-- NHL official_site source seed

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
    'official_site',
    'https://www.nhl.com/news',
    NULL,
    'en',
    'US',
    true,
    true,
    'Primary NHL official news page for MEDIA scraper layer'
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
    is_active,
    notes
FROM public.content_sources
WHERE name = 'NHL'
ORDER BY id;