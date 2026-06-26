/*
===============================================================================
MATCHMATRIX SQL 120_Q_L
CONTEXT SEARCH FUNCTION V2
===============================================================================

CO TO JE:
- Vylepšená vyhledávací funkce Universal Context Resolveru.

K ČEMU TO JE:
- Omezí zahlcení výsledků zápasy při jednoduchém hledání týmu.

KDE TO UVIDÍME:
- Web Search
- AI Search
- Mobile App
- Team / Player / Match Pages

JAK SE TO VYUŽIJE:
- "Barcelona" vrátí hlavně týmy.
- "Barcelona vs Real Madrid" vrátí hlavně zápasy.
===============================================================================
*/

CREATE OR REPLACE FUNCTION ops.fn_context_search_v2(
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

WITH scored AS (
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

            + CASE
                WHEN lower(r.search_text) = lower(p_query) THEN 1000
                WHEN lower(r.search_text) LIKE lower(p_query) || '%' THEN 500
                WHEN lower(r.search_text) LIKE '%' || lower(p_query) || '%' THEN 200
                ELSE 0
              END

            + CASE
                WHEN r.source_type = 'CANONICAL' THEN 50
                ELSE 0
              END

            + CASE
                WHEN r.entity_type = 'TEAM' THEN 250
                WHEN r.entity_type = 'PLAYER' THEN 180
                WHEN r.entity_type = 'LEAGUE' THEN 160
                WHEN r.entity_type = 'COACH' THEN 120
                WHEN r.entity_type = 'ARTICLE' THEN 40
                ELSE 0
              END

            - CASE
                WHEN r.entity_type = 'MATCH'
                 AND lower(p_query) NOT LIKE '% vs %'
                 AND array_length(regexp_split_to_array(trim(p_query), '\s+'), 1) <= 2
                THEN 350
                ELSE 0
              END

        )::numeric AS final_score

    FROM ops.v_context_search_resolver_v1 r
    WHERE lower(r.search_text) LIKE '%' || lower(p_query) || '%'
),

dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY entity_type, entity_id
            ORDER BY final_score DESC, source_type
        ) AS rn
    FROM scored
)

SELECT
    entity_type,
    entity_id,
    search_text,
    canonical_name,
    sport_id,
    country,
    source_type,
    final_score
FROM dedup
WHERE rn = 1
ORDER BY final_score DESC, entity_type, canonical_name
LIMIT p_limit;

$$;