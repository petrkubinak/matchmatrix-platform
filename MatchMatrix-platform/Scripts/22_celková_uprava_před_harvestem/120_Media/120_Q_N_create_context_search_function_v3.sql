/*
===============================================================================
MATCHMATRIX SQL 120_Q_N
CONTEXT SEARCH FUNCTION V3
===============================================================================

CO TO JE:
- Vylepšená vyhledávací funkce Universal Context Resolveru s režimy dotazu.

K ČEMU TO JE:
- Oddělí jednoduché hledání entity od hledání konkrétního zápasu.

KDE TO UVIDÍME:
- Web Search
- AI Search
- Mobile App
- Team / Player / Match Pages

JAK SE TO VYUŽIJE:
- "Barcelona" vrátí hlavně týmy.
- "Barcelona vs Real Madrid" vrátí hlavně zápasy.
- "NHL" vrátí hlavně ligu a články, ne náhodné zápasy.
===============================================================================
*/

CREATE OR REPLACE FUNCTION ops.fn_context_search_v3(
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
    query_mode TEXT,
    final_score NUMERIC
)
LANGUAGE sql
AS $$

WITH query_meta AS (
    SELECT
        p_query AS q,
        lower(trim(p_query)) AS q_lower,
        array_length(regexp_split_to_array(trim(p_query), '\s+'), 1) AS token_count,
        CASE
            WHEN lower(p_query) LIKE '% vs %'
              OR lower(p_query) LIKE '% v %'
              OR lower(p_query) LIKE '%match%'
              OR lower(p_query) LIKE '%zápas%'
            THEN 'MATCH_QUERY'

            WHEN lower(p_query) LIKE '%news%'
              OR lower(p_query) LIKE '%article%'
              OR lower(p_query) LIKE '%preview%'
              OR lower(p_query) LIKE '%lineup%'
            THEN 'MEDIA_QUERY'

            ELSE 'SINGLE_ENTITY_QUERY'
        END AS query_mode
),

scored AS (
    SELECT
        r.entity_type,
        r.entity_id,
        r.search_text,
        r.canonical_name,
        r.sport_id,
        r.country,
        r.source_type,
        qm.query_mode,

        (
            r.search_priority

            + CASE
                WHEN lower(r.search_text) = qm.q_lower THEN 1000
                WHEN lower(r.search_text) LIKE qm.q_lower || '%' THEN 500
                WHEN lower(r.search_text) LIKE '%' || qm.q_lower || '%' THEN 200
                ELSE 0
              END

            + CASE
                WHEN r.source_type = 'CANONICAL' THEN 50
                ELSE 0
              END

            + CASE
                WHEN qm.query_mode = 'SINGLE_ENTITY_QUERY' AND r.entity_type = 'TEAM' THEN 450
                WHEN qm.query_mode = 'SINGLE_ENTITY_QUERY' AND r.entity_type = 'PLAYER' THEN 380
                WHEN qm.query_mode = 'SINGLE_ENTITY_QUERY' AND r.entity_type = 'LEAGUE' THEN 360
                WHEN qm.query_mode = 'SINGLE_ENTITY_QUERY' AND r.entity_type = 'COACH' THEN 250
                WHEN qm.query_mode = 'SINGLE_ENTITY_QUERY' AND r.entity_type = 'ARTICLE' THEN 20
                WHEN qm.query_mode = 'SINGLE_ENTITY_QUERY' AND r.entity_type = 'MATCH' THEN -700

                WHEN qm.query_mode = 'MATCH_QUERY' AND r.entity_type = 'MATCH' THEN 800
                WHEN qm.query_mode = 'MATCH_QUERY' AND r.entity_type = 'TEAM' THEN 250
                WHEN qm.query_mode = 'MATCH_QUERY' AND r.entity_type = 'ARTICLE' THEN 120

                WHEN qm.query_mode = 'MEDIA_QUERY' AND r.entity_type = 'ARTICLE' THEN 500
                WHEN qm.query_mode = 'MEDIA_QUERY' AND r.entity_type = 'TEAM' THEN 200
                WHEN qm.query_mode = 'MEDIA_QUERY' AND r.entity_type = 'PLAYER' THEN 180

                ELSE 0
              END

        )::numeric AS final_score

    FROM ops.v_context_search_resolver_v1 r
    CROSS JOIN query_meta qm
    WHERE lower(r.search_text) LIKE '%' || qm.q_lower || '%'
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
    query_mode,
    final_score
FROM dedup
WHERE rn = 1
ORDER BY final_score DESC, entity_type, canonical_name
LIMIT p_limit;

$$;