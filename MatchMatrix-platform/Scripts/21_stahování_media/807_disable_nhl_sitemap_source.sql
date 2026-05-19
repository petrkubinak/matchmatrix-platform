-- 807_disable_nhl_sitemap_source.sql
-- Disable NHL sitemap source after HTTP 403

UPDATE public.content_sources
SET
    is_active = false,
    notes = COALESCE(notes, '') || ' | Disabled after HTTP 403 on sitemap.xml.',
    updated_at = now()
WHERE name = 'NHL'
  AND source_type = 'sitemap';

SELECT
    id,
    name,
    source_type,
    rss_url,
    is_active,
    notes
FROM public.content_sources
WHERE name = 'NHL'
ORDER BY id;