/*
===============================================================================
MATCHMATRIX SQL 120_Q_J_3
CONTEXT SEARCH RESOLVER V1
===============================================================================

CO TO JE:
- První univerzální vyhledávací resolver MatchMatrix.

K ČEMU TO JE:
- Spojí entity a aliasy do jednoho vyhledávacího pohledu.

KDE TO UVIDÍME:
- Web Search
- AI Search
- Mobile App
- Match Search
- Team Search
- Player Search

JAK SE TO VYUŽIJE:
- Uživatel zadá:
    Barcelona
    Barca
    Real Madrid
    Premier League
    Lamine Yamal

- Resolver vrátí odpovídající entity.
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_context_search_resolver_v1 AS

/* CANONICAL NÁZVY */

SELECT
    r.entity_type,
    r.entity_id,
    r.canonical_name AS search_text,
    r.canonical_name,
    r.sport_id,
    r.country,
    r.search_priority,
    'CANONICAL' AS source_type

FROM public.context_entity_registry r

WHERE r.is_active = TRUE

UNION ALL

/* ALIASY */

SELECT
    a.entity_type,
    a.entity_id,
    a.alias_text AS search_text,
    r.canonical_name,
    r.sport_id,
    r.country,
    r.search_priority + a.alias_priority AS search_priority,
    'ALIAS' AS source_type

FROM public.context_alias_registry a

JOIN public.context_entity_registry r
    ON r.entity_type = a.entity_type
   AND r.entity_id = a.entity_id

WHERE r.is_active = TRUE;