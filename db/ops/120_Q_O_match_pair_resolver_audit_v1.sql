/*
===============================================================================
MATCHMATRIX SQL 120_Q_O
MATCH PAIR RESOLVER AUDIT V1
===============================================================================

CO TO JE:
- Audit potenciálních dvojic týmů pro Match Resolver.

K ČEMU TO JE:
- Ověření, že systém správně rozpozná:
    Barcelona vs Real Madrid

a ne:
    Espanyol Barcelona vs Real Madrid

KDE TO UVIDÍME:
- AI Search
- Match Search
- Match Context Engine
- Budoucí Chat AI

JAK SE TO VYUŽIJE:
- Budoucí fn_context_match_search_v1()
===============================================================================
*/

WITH team_candidates AS (

    SELECT
        entity_id AS team_id,
        canonical_name,
        sport_id,
        search_priority
    FROM public.context_entity_registry
    WHERE entity_type='TEAM'

),

alias_candidates AS (

    SELECT
        a.entity_id AS team_id,
        a.alias_text
    FROM public.context_alias_registry a
    WHERE a.entity_type='TEAM'

)

SELECT
    t.team_id,
    t.canonical_name,
    t.sport_id,
    COUNT(a.alias_text) AS alias_count,
    MAX(length(a.alias_text)) AS longest_alias_length
FROM team_candidates t
LEFT JOIN alias_candidates a
    ON a.team_id=t.team_id
GROUP BY
    t.team_id,
    t.canonical_name,
    t.sport_id
ORDER BY alias_count DESC,
         canonical_name;