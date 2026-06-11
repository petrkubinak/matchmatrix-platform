/*
MATCHMATRIX SQL 120_J LaLiga Article Match Best Candidate V1

CO TO JE:
- Vybere nejlepší match_id pro La Liga media články.

K ČEMU TO JE:
- Odstraní falešný match Espanyol vs Real Madrid.
- Připraví bezpečný návrh pro article_match_map.

KDE TO UVIDÍME:
- OPS / Media Command Center / Match Context Engine.

JAK SE TO VYUŽIJE:
- Další krok bude bezpečný INSERT do public.article_match_map.
*/

CREATE OR REPLACE VIEW ops.v_laliga_article_match_best_candidate_v1 AS
WITH candidates AS (
    SELECT
        a.id AS article_id,
        a.title,
        a.published_at,

        m.id AS match_id,
        m.kickoff,
        ht.name AS home_team,
        at.name AS away_team,
        l.name AS league_name,
        m.season,
        m.ext_source,
        m.ext_match_id,

        ABS(EXTRACT(EPOCH FROM (a.published_at - m.kickoff)) / 86400.0) AS days_distance,

        CASE
            WHEN a.title ILIKE '%Barcelona%'
             AND a.title ILIKE '%Real Madrid%'
             AND ht.name NOT ILIKE '%Espanyol%'
             AND at.name NOT ILIKE '%Espanyol%'
             AND (
                  (ht.name ILIKE '%Barcelona%' AND at.name ILIKE '%Real Madrid%')
               OR (ht.name ILIKE '%Real Madrid%' AND at.name ILIKE '%Barcelona%')
             )
            THEN 'BARCELONA_REAL_MADRID'

            WHEN a.title ILIKE '%Betis%'
             AND a.title ILIKE '%Real Madrid%'
             AND (
                  (ht.name ILIKE '%Betis%' AND at.name ILIKE '%Real Madrid%')
               OR (ht.name ILIKE '%Real Madrid%' AND at.name ILIKE '%Betis%')
             )
            THEN 'BETIS_REAL_MADRID'

            ELSE 'NO_MATCH'
        END AS resolution_rule

    FROM public.articles a
    JOIN public.matches m
        ON m.kickoff BETWEEN a.published_at - INTERVAL '45 days'
                         AND a.published_at + INTERVAL '45 days'
    JOIN public.teams ht
        ON ht.id = m.home_team_id
    JOIN public.teams at
        ON at.id = m.away_team_id
    JOIN public.leagues l
        ON l.id = m.league_id
    WHERE a.id IN (406,405,404,402,399,389)
      AND l.name IN ('La Liga', 'Primera Division')
)
SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY article_id
            ORDER BY
                CASE WHEN resolution_rule <> 'NO_MATCH' THEN 1 ELSE 0 END DESC,
                days_distance ASC,
                CASE
                    WHEN ext_source = 'football_data' THEN 100
                    WHEN ext_source = 'api_football' THEN 90
                    WHEN ext_source = 'football_data_uk' THEN 70
                    ELSE 50
                END DESC
        ) AS best_rank
    FROM candidates
    WHERE resolution_rule <> 'NO_MATCH'
) x
WHERE best_rank = 1;