/*
===============================================================================
MATCHMATRIX SQL 120_Q_K
CONTEXT SEARCH FUNCTION V1
===============================================================================

CO TO JE:
- První vyhledávací funkce Universal Context Resolveru.

K ČEMU TO JE:
- Vrací nejlepší entity podle hledaného textu.

KDE TO UVIDÍME:
- Web Search
- AI Search
- Mobile App
- Match Pages
- Team Pages
- Player Pages

JAK SE TO VYUŽIJE:
- SELECT * FROM ops.fn_context_search_v1('barcelona');
===============================================================================
*/

CREATE OR REPLACE FUNCTION ops.fn_context_search_v1(
    p_query TEXT,
    p_limit INTEGER DEFAULT 25
)
RETURNS TABLE (
    entity_type TEXT,
    entity_id BIGINT,
    search_text TEXT,
    canonical_name TEXT,
    sport_id BIGINT,
    country TEXT,
    source_type TEXT,
    final_score NUMERIC
)
LANGUAGE sql
AS $$

SELECT
    r.entity_type,
    r.entity_id,
    r.search_text,
    r.canonical_name,
    r.sport_id,
    r.country,
    r.source_type,

    (
        r.search_priority
        +
        CASE
            WHEN lower(r.search_text) = lower(p_query) THEN 1000
            WHEN lower(r.search_text) LIKE lower(p_query) || '%' THEN 500
            WHEN lower(r.search_text) LIKE '%' || lower(p_query) || '%' THEN 200
            ELSE 0
        END
        +
        CASE
            WHEN r.source_type = 'CANONICAL' THEN 50
            ELSE 0
        END
    )::numeric AS final_score

FROM ops.v_context_search_resolver_v1 r
WHERE lower(r.search_text) LIKE '%' || lower(p_query) || '%'
ORDER BY final_score DESC, r.entity_type, r.canonical_name
LIMIT p_limit;

$$;