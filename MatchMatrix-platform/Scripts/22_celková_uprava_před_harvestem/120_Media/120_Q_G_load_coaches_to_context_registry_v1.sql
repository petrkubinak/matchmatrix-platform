/*
===============================================================================
MATCHMATRIX SQL 120_Q_G
COACH LOADER TO CONTEXT REGISTRY V1
===============================================================================

CO TO JE:
- Naplnění Universal Context Resolveru trenéry z public.coaches.

K ČEMU TO JE:
- Aby vyhledávání MatchMatrix umělo najít trenéry napříč sporty.

KDE TO UVIDÍME:
- Web Search
- AI Search
- Coach Pages
- Team Pages
- Match Pages
- Ticket Engine

JAK SE TO VYUŽIJE:
- Uživatel zadá jméno trenéra.
- Resolver vrátí COACH entitu a její návaznosti na týmy, zápasy a články.
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
    'COACH',
    c.id,
    COALESCE(
        NULLIF(c.name, ''),
        NULLIF(TRIM(COALESCE(c.first_name,'') || ' ' || COALESCE(c.last_name,'')), ''),
        c.short_name
    ) AS canonical_name,
    c.sport_id,
    COALESCE(c.nationality, c.birth_country),
    75
FROM public.coaches c
WHERE COALESCE(
        NULLIF(c.name, ''),
        NULLIF(TRIM(COALESCE(c.first_name,'') || ' ' || COALESCE(c.last_name,'')), ''),
        c.short_name
    ) IS NOT NULL
  AND NOT EXISTS
(
    SELECT 1
    FROM public.context_entity_registry r
    WHERE r.entity_type = 'COACH'
      AND r.entity_id = c.id
);