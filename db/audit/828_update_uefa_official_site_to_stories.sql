-- 828_update_uefa_official_site_to_stories.sql
-- UEFA official_site switch from news landing page to stories page

UPDATE public.content_sources
SET
    base_url = 'https://www.uefa.com/news-media/stories/',
    notes = COALESCE(notes, '') || ' | Switched from /news/ to /stories/ after inspect showed /news/ is only landing page.',
    updated_at = now()
WHERE name = 'UEFA'
  AND source_type = 'official_site';

SELECT
    id,
    name,
    source_type,
    base_url,
    is_active,
    notes
FROM public.content_sources
WHERE name = 'UEFA'
ORDER BY id;