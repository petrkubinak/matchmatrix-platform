/*
===============================================================================
MATCHMATRIX SQL 120_Q_R
MATCH CONTEXT ENGINE V1
===============================================================================

CO TO JE:
- První verze Match Context Engine.

K ČEMU TO JE:
- Vrací souhrnný kontext mezi dvěma týmy.
- Základ pro AI Search, Match Pages a Ticket Engine.

KDE TO UVIDÍME:
- Web Search
- AI Chat
- Team Pages
- Match Pages
- Ticket Suggestions

JAK SE TO VYUŽIJE:
SELECT *
FROM ops.fn_match_context_engine_v1(
    'barcelona',
    'real madrid',
    1
);
===============================================================================
*/

CREATE OR REPLACE FUNCTION ops.fn_match_context_engine_v1(
    p_team_a TEXT,
    p_team_b TEXT,
    p_sport_id BIGINT DEFAULT NULL
)
RETURNS TABLE (
    metric_name TEXT,
    metric_value TEXT
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

stats AS (

    SELECT
        COUNT(*) AS total_matches,

        COUNT(*) FILTER (
            WHERE status ILIKE '%FINISHED%'
        ) AS finished_matches,

        MIN(kickoff) AS first_match,

        MAX(kickoff) AS last_match

    FROM h2h

),

next_match AS (

    SELECT
        kickoff,
        home_team,
        away_team,
        league_name
    FROM h2h
    WHERE kickoff > NOW()
    ORDER BY kickoff
    LIMIT 1

),

last_match AS (

    SELECT
        kickoff,
        home_team,
        away_team,
        league_name
    FROM h2h
    ORDER BY kickoff DESC
    LIMIT 1

),

league_summary AS (

    SELECT
        STRING_AGG(
            DISTINCT league_name,
            ', '
            ORDER BY league_name
        ) AS leagues
    FROM h2h

)

SELECT
    'TOTAL_MATCHES',
    total_matches::text
FROM stats

UNION ALL

SELECT
    'FINISHED_MATCHES',
    finished_matches::text
FROM stats

UNION ALL

SELECT
    'FIRST_MATCH',
    COALESCE(first_match::text,'')
FROM stats

UNION ALL

SELECT
    'LAST_MATCH_DATE',
    COALESCE(last_match::text,'')
FROM stats

UNION ALL

SELECT
    'NEXT_MATCH',
    COALESCE(
        home_team || ' vs ' ||
        away_team || ' | ' ||
        league_name || ' | ' ||
        kickoff,
        ''
    )
FROM next_match

UNION ALL

SELECT
    'LAST_MATCH',
    COALESCE(
        home_team || ' vs ' ||
        away_team || ' | ' ||
        league_name || ' | ' ||
        kickoff,
        ''
    )
FROM last_match

UNION ALL

SELECT
    'LEAGUES',
    COALESCE(leagues,'')
FROM league_summary

$$;