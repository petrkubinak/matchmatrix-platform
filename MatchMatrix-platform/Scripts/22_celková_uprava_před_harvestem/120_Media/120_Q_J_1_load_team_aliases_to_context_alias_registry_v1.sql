/*
===============================================================================
MATCHMATRIX SQL 120_Q_J_1
TEAM ALIAS LOADER TO CONTEXT ALIAS REGISTRY V1
===============================================================================

CO TO JE:
- Naplnění Universal Context Resolveru týmovými aliasy.

K ČEMU TO JE:
- Aby vyhledávání našlo týmy i přes zkratky, alternativní názvy a provider názvy.

KDE TO UVIDÍME:
- Web Search
- AI Search
- Team Pages
- Match Pages
- Ticket Engine

JAK SE TO VYUŽIJE:
- Uživatel zadá alias týmu.
- Resolver vrátí TEAM entitu.
===============================================================================
*/

INSERT INTO public.context_alias_registry
(
    entity_type,
    entity_id,
    alias_text,
    alias_priority
)
SELECT
    'TEAM',
    ta.team_id,
    ta.alias,
    100
FROM public.team_aliases ta
WHERE ta.alias IS NOT NULL
  AND trim(ta.alias) <> ''
  AND NOT EXISTS
(
    SELECT 1
    FROM public.context_alias_registry r
    WHERE r.entity_type = 'TEAM'
      AND r.entity_id = ta.team_id
      AND lower(trim(r.alias_text)) = lower(trim(ta.alias))
);