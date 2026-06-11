/*
===============================================================================
MATCHMATRIX SQL 120_Q_S
MATCH CONTEXT ENGINE V2 - FIXED ORDER BY
===============================================================================

CO TO JE:
- Rozšíření Match Context Engine V1.

K ČEMU TO JE:
- Vrací poslední vzájemné zápasy.
- Vrací články související s dvojicí týmů.

KDE TO UVIDÍME:
- Match Detail
- AI Search
- AI Chat
- Team Pages
- Ticket Engine

JAK SE TO VYUŽIJE:
SELECT *
FROM ops.fn_match_context_engine_v2(
    'barcelona',
    'real madrid',
    1
);
===============================================================================
*/

CREATE OR REPLACE FUNCTION ops.fn_match_context_engine_v2(
    p_team_a TEXT,
    p_team_b TEXT,
    p_sport_id BIGINT DEFAULT NULL
)
RETURNS TABLE (
    section_name TEXT,
    item_order INTEGER,
    item_value TEXT
)
LANGUAGE sql
AS $$

WITH h2h AS (

    SELECT *
    FROM ops.fn_context_match_pair_search_v2(
        p_team_a,
        p_team_b,
        p_sport_id,
        1000
    )

),

summary AS (

    SELECT
        COUNT(*) total_matches,
        COUNT(*) FILTER (
            WHERE status ILIKE '%FINISHED%'
        ) finished_matches
    FROM h2h

),

last5 AS (

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY kickoff DESC
        )::integer AS rn,

        home_team
        || ' vs '
        || away_team
        || ' | '
        || COALESCE(league_name,'')
        || ' | '
        || kickoff::date AS match_text

    FROM h2h
    ORDER BY kickoff DESC
    LIMIT 5

),

articles AS (

    SELECT
        ROW_NUMBER() OVER (
            ORDER BY id DESC
        )::integer AS rn,

        title

    FROM public.articles
    WHERE lower(title) LIKE '%' || lower(p_team_a) || '%'
       OR lower(title) LIKE '%' || lower(p_team_b) || '%'
    LIMIT 10

),

final_output AS (

    SELECT
        'SUMMARY'::text AS section_name,
        1::integer AS item_order,
        ('TOTAL_MATCHES=' || total_matches)::text AS item_value
    FROM summary

    UNION ALL

    SELECT
        'SUMMARY'::text AS section_name,
        2::integer AS item_order,
        ('FINISHED_MATCHES=' || finished_matches)::text AS item_value
    FROM summary

    UNION ALL

    SELECT
        'LAST_5_MATCHES'::text AS section_name,
        rn::integer AS item_order,
        match_text::text AS item_value
    FROM last5

    UNION ALL

    SELECT
        'RELATED_ARTICLES'::text AS section_name,
        rn::integer AS item_order,
        title::text AS item_value
    FROM articles

)

SELECT
    section_name,
    item_order,
    item_value
FROM final_output
ORDER BY
    section_name,
    item_order;

$$;