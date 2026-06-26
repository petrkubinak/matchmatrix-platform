/*
===============================================================================
MATCHMATRIX SQL 120_Q_E
LEAGUE LOADER TO CONTEXT REGISTRY V1
===============================================================================

CO TO JE:
- Naplnění Universal Context Resolveru ligami.

K ČEMU TO JE:
- Vyhledávání soutěží napříč MatchMatrix.

KDE TO UVIDÍME:
- Web Search
- AI Search
- League Pages
- Match Pages
- Ticket Engine

JAK SE TO VYUŽIJE:
- Uživatel napíše:
  Premier League
  NHL
  La Liga
  Bundesliga

- Resolver vrátí LEAGUE entitu.
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
    'LEAGUE',
    l.id,
    l.name,
    l.sport_id,
    l.country,
    90
FROM public.leagues l
WHERE NOT EXISTS
(
    SELECT 1
    FROM public.context_entity_registry r
    WHERE r.entity_type = 'LEAGUE'
      AND r.entity_id = l.id
);