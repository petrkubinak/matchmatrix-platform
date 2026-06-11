/*
===============================================================================
MATCHMATRIX SQL 120_Q_T
MATCH CONTEXT ENGINE V3
===============================================================================

CO TO JE:
- Opravený Match Context Engine.
- Používá pouze nejlepší dvojici týmů podle score.

K ČEMU TO JE:
- Aby "Barcelona vs Real Madrid" nevracelo Espanyol, Barcelona B, Barcelona II.

KDE TO UVIDÍME:
- AI Search
- Match Detail
- Team Pages
- Ticket Engine

JAK SE TO VYUŽIJE:
SELECT *
FROM ops.fn_match_context_engine_v3('barcelona','real madrid',1);
===============================================================================
*/

CREATE OR REPLACE FUNCTION ops.fn_match_context_engine_v3(
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

WITH raw_h2h AS (

    SELECT *
    FROM ops.fn_context_match_pair_search_v2(
        p_team_a,
        p_team_b,
        p_sport_id,
        1000
    )

),

best_score AS (

    SELECT MAX(final_score) AS max_score
    FROM raw_h2h

),

h2h AS (

    SELECT r.*
    FROM raw_h2h r
    CROSS JOIN best_score b
    WHERE r.final_score >= b.max_score - 100

),

summary AS (

    SELECT
        COUNT(*) AS total_matches,
        COUNT(*) FILTER (
            WHERE status ILIKE '%FINISHED%'
        ) AS finished_matches
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
        'SUMMARY'::text,
        2::integer,
        ('FINISHED_MATCHES=' || finished_matches)::text
    FROM summary

    UNION ALL

    SELECT
        'LAST_5_MATCHES'::text,
        rn,
        match_text::text
    FROM last5

    UNION ALL

    SELECT
        'RELATED_ARTICLES'::text,
        rn,
        title::text
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