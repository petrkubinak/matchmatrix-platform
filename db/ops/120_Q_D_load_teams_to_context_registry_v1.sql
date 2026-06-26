/*
===============================================================================
MATCHMATRIX SQL 120_Q_D
TEAM LOADER TO CONTEXT REGISTRY V1
===============================================================================

CO TO JE:
- Naplnění Universal Context Resolveru týmy z public.teams.

K ČEMU TO JE:
- Aby vyhledávání MatchMatrix umělo najít týmy napříč sporty.

KDE TO UVIDÍME:
- Web Search
- AI Search
- Team Pages
- Match Pages
- Ticket Engine

JAK SE TO VYUŽIJE:
- Uživatel zadá tým nebo alias.
- Resolver vrátí TEAM entitu a její návaznosti.
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
    'TEAM',
    t.id,
    t.name,
    t.sport_id,
    NULL,
    100
FROM public.teams t
WHERE NOT EXISTS
(
    SELECT 1
    FROM public.context_entity_registry r
    WHERE r.entity_type = 'TEAM'
      AND r.entity_id = t.id
);