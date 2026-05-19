UPDATE public.media_entity_aliases
SET entity_id = 23344,
    updated_at = now()
WHERE entity_type = 'league'
  AND source_scope = 'NBA'
  AND alias_text IN ('NBA', 'NBA Playoffs');

UPDATE public.media_entity_aliases
SET entity_id = 22390,
    updated_at = now()
WHERE entity_type = 'league'
  AND source_scope = 'NHL'
  AND alias_text IN ('NHL', 'Stanley Cup', 'Stanley Cup Playoffs');

UPDATE public.media_entity_aliases
SET entity_id = 20969,
    updated_at = now()
WHERE entity_type = 'league'
  AND source_scope = 'UEFA'
  AND alias_text IN ('UEFA Champions League', 'Champions League', 'UCL');

SELECT
    entity_type,
    entity_id,
    alias_text,
    source_scope,
    provider_scope,
    is_active
FROM public.media_entity_aliases
ORDER BY source_scope, alias_text;