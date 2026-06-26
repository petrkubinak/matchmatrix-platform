/*
===============================================================================
MATCHMATRIX SQL 120_Q_F
PLAYER LOADER TO CONTEXT REGISTRY V1
===============================================================================

CO TO JE:
- Naplnění Universal Context Resolveru hráči z public.players.

K ČEMU TO JE:
- Aby vyhledávání MatchMatrix umělo najít hráče napříč sporty.

KDE TO UVIDÍME:
- Web Search
- AI Search
- Player Pages
- Match Pages
- Ticket Engine

JAK SE TO VYUŽIJE:
- Uživatel zadá jméno hráče.
- Resolver vrátí PLAYER entitu a její návaznosti.
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
    'PLAYER',
    p.id,
    COALESCE(NULLIF(p.name, ''), trim(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,''))),
    p.sport_id,
    p.nationality,
    80
FROM public.players p
WHERE COALESCE(NULLIF(p.name, ''), trim(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,''))) IS NOT NULL
  AND COALESCE(NULLIF(p.name, ''), trim(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,''))) <> ''
  AND NOT EXISTS
(
    SELECT 1
    FROM public.context_entity_registry r
    WHERE r.entity_type = 'PLAYER'
      AND r.entity_id = p.id
);