/*
===============================================================================
MATCHMATRIX SQL 120_Q_H
ARTICLE LOADER TO CONTEXT REGISTRY V1
===============================================================================

CO TO JE:
- Naplnění Universal Context Resolveru články z public.articles.

K ČEMU TO JE:
- Aby vyhledávání MatchMatrix umělo najít články, preview, reporty a media obsah.

KDE TO UVIDÍME:
- Web Search
- AI Search
- Match Pages
- Team Pages
- Player Pages
- Media Feed

JAK SE TO VYUŽIJE:
- Uživatel zadá téma, tým, hráče nebo zápas.
- Resolver nabídne relevantní ARTICLE entity.
===============================================================================
*/

INSERT INTO public.context_entity_registry
(
    entity_type,
    entity_id,
    canonical_name,
    sport_id,
    country,
    search_priority
)
SELECT
    'ARTICLE',
    a.id,
    a.title,
    NULL,
    NULL,
    60
FROM public.articles a
WHERE a.title IS NOT NULL
  AND trim(a.title) <> ''
  AND NOT EXISTS
(
    SELECT 1
    FROM public.context_entity_registry r
    WHERE r.entity_type = 'ARTICLE'
      AND r.entity_id = a.id
);