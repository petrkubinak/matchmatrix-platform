-- 830_seed_fifa_official_site_source.sql
-- FIFA official_site source seed

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
    'FIFA',
    'official_site',
    'https://www.fifa.com/en/news',
    NULL,
    'en',
    'WORLD',
    true,
    true,
    'Primary FIFA official news source for MEDIA layer'
)
ON CONFLICT (name, source_type)
DO UPDATE SET
    base_url = EXCLUDED.base_url,
    is_active = true,
    updated_at = now();

SELECT
    id,
    name,
    source_type,
    base_url,
    is_active
FROM public.content_sources
WHERE name = 'FIFA'
ORDER BY id;