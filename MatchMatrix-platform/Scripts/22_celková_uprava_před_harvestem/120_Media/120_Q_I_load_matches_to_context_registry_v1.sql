/*
===============================================================================
MATCHMATRIX SQL 120_Q_I
MATCH LOADER TO CONTEXT REGISTRY V1
===============================================================================

CO TO JE:
- Naplnění Universal Context Resolveru zápasy z public.matches.

K ČEMU TO JE:
- Aby vyhledávání MatchMatrix umělo najít konkrétní zápasy.

KDE TO UVIDÍME:
- Web Search
- AI Search
- Match Pages
- Team Pages
- Ticket Engine
- Predikce

JAK SE TO VYUŽIJE:
- Uživatel zadá například:
  Barcelona Real Madrid
  Manchester United Liverpool
  NHL Ducks
- Resolver vrátí MATCH entitu s návazností na týmy, ligu a datum.
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
    'MATCH',
    m.id,
    COALESCE(ht.name, 'UNKNOWN_HOME')
        || ' vs '
        || COALESCE(at.name, 'UNKNOWN_AWAY')
        || ' | '
        || COALESCE(l.name, 'UNKNOWN_LEAGUE')
        || ' | '
        || COALESCE(m.season, 'UNKNOWN_SEASON'),
    m.sport_id,
    l.country,
    70
FROM public.matches m
LEFT JOIN public.teams ht
    ON ht.id = m.home_team_id
LEFT JOIN public.teams at
    ON at.id = m.away_team_id
LEFT JOIN public.leagues l
    ON l.id = m.league_id
WHERE NOT EXISTS
(
    SELECT 1
    FROM public.context_entity_registry r
    WHERE r.entity_type = 'MATCH'
      AND r.entity_id = m.id
);