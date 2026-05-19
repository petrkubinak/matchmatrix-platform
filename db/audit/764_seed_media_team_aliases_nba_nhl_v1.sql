BEGIN;

INSERT INTO public.media_entity_aliases
(
    entity_type,
    entity_id,
    alias_text,
    source_scope,
    provider_scope
)
SELECT
    'team',
    t.id,
    'Cavaliers',
    'NBA',
    'nba_official_site'
FROM public.teams t
WHERE t.name = 'Cavaliers'
ON CONFLICT DO NOTHING;

INSERT INTO public.media_entity_aliases
(
    entity_type,
    entity_id,
    alias_text,
    source_scope,
    provider_scope
)
SELECT
    'team',
    t.id,
    'Warriors',
    'NBA',
    'nba_official_site'
FROM public.teams t
WHERE t.name = 'Warriors'
ON CONFLICT DO NOTHING;

COMMIT;

SELECT
    entity_type,
    entity_id,
    alias_text,
    source_scope,
    provider_scope,
    is_active
FROM public.media_entity_aliases
WHERE entity_type = 'team'
ORDER BY source_scope, alias_text;