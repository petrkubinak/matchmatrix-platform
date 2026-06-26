/*
===============================================================================
MATCHMATRIX SQL 120_Q_P
MATCH PAIR RESOLVER V1
===============================================================================

CO TO JE:
- Funkce pro hledání zápasů podle dvojice týmů.

K ČEMU TO JE:
- Aby dotaz typu "Barcelona vs Real Madrid" nehledal jen textově,
  ale nejdřív našel TEAM_A a TEAM_B.

KDE TO UVIDÍME:
- AI Search
- Web Search
- Match Pages
- Ticket Engine
- Match Context Engine

JAK SE TO VYUŽIJE:
- SELECT * FROM ops.fn_context_match_pair_search_v1('barcelona', 'real madrid', 30);
===============================================================================
*/

CREATE OR REPLACE FUNCTION ops.fn_context_match_pair_search_v1(
    p_team_a TEXT,
    p_team_b TEXT,
    p_limit INTEGER DEFAULT 30
)
RETURNS TABLE (
    match_id BIGINT,
    kickoff TIMESTAMP,
    status TEXT,
    home_team_id BIGINT,
    home_team TEXT,
    away_team_id BIGINT,
    away_team TEXT,
    league_id BIGINT,
    league_name TEXT,
    season TEXT,
    sport_id BIGINT,
    ext_source TEXT,
    ext_match_id TEXT,
    team_a_match_name TEXT,
    team_b_match_name TEXT,
    final_score NUMERIC
)
LANGUAGE sql
AS $$

WITH team_a AS (
    SELECT
        entity_id::bigint AS team_id,
        canonical_name,
        sport_id,
        final_score
    FROM ops.fn_context_search_v3(p_team_a, 20)
    WHERE entity_type = 'TEAM'
),

team_b AS (
    SELECT
        entity_id::bigint AS team_id,
        canonical_name,
        sport_id,
        final_score
    FROM ops.fn_context_search_v3(p_team_b, 20)
    WHERE entity_type = 'TEAM'
),

team_pairs AS (
    SELECT
        a.team_id AS team_a_id,
        a.canonical_name AS team_a_name,
        b.team_id AS team_b_id,
        b.canonical_name AS team_b_name,
        a.sport_id,
        (a.final_score + b.final_score) AS pair_score
    FROM team_a a
    JOIN team_b b
        ON a.sport_id IS NOT DISTINCT FROM b.sport_id
       AND a.team_id <> b.team_id
)

SELECT
    m.id::bigint AS match_id,
    m.kickoff,
    m.status,
    ht.id::bigint AS home_team_id,
    ht.name AS home_team,
    at.id::bigint AS away_team_id,
    at.name AS away_team,
    l.id::bigint AS league_id,
    l.name AS league_name,
    m.season,
    m.sport_id::bigint,
    m.ext_source,
    m.ext_match_id,

    tp.team_a_name AS team_a_match_name,
    tp.team_b_name AS team_b_match_name,

    (
        tp.pair_score
        + CASE
            WHEN m.status ILIKE '%SCHEDULED%' THEN 150
            WHEN m.status ILIKE '%FINISHED%' THEN 80
            ELSE 50
          END
        + CASE
            WHEN m.kickoff >= NOW() - INTERVAL '365 days' THEN 120
            ELSE 0
          END
    )::numeric AS final_score

FROM team_pairs tp
JOIN public.matches m
    ON (
           (m.home_team_id = tp.team_a_id AND m.away_team_id = tp.team_b_id)
        OR (m.home_team_id = tp.team_b_id AND m.away_team_id = tp.team_a_id)
    )
JOIN public.teams ht
    ON ht.id = m.home_team_id
JOIN public.teams at
    ON at.id = m.away_team_id
LEFT JOIN public.leagues l
    ON l.id = m.league_id

ORDER BY final_score DESC, m.kickoff DESC
LIMIT p_limit;

$$;