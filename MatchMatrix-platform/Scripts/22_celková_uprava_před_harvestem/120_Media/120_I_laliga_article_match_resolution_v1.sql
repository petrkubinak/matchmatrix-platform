/*
MATCHMATRIX SQL 120_I LaLiga Article Match Resolution V1

CO TO JE:
- Bezpečný test resolver pro La Liga články typu Barcelona vs Real Madrid / Betis v Real Madrid.

K ČEMU TO JE:
- Ověří, jestli umíme najít správný match_id pro články bez šumu z jiných sportů.

KDE TO UVIDÍME:
- OPS / Media Command Center / Match Context Engine.

JAK SE TO VYUŽIJE:
- Po ověření vznikne obecný Match Context Resolver.
*/

CREATE OR REPLACE VIEW ops.v_laliga_article_match_resolution_v1 AS
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
  AND (
        (
            a.title ILIKE '%Barcelona%'
            AND a.title ILIKE '%Real Madrid%'
            AND (
                 (ht.name ILIKE '%Barcelona%' AND at.name ILIKE '%Real Madrid%')
              OR (ht.name ILIKE '%Real Madrid%' AND at.name ILIKE '%Barcelona%')
            )
        )
        OR
        (
            a.title ILIKE '%Betis%'
            AND a.title ILIKE '%Real Madrid%'
            AND (
                 (ht.name ILIKE '%Betis%' AND at.name ILIKE '%Real Madrid%')
              OR (ht.name ILIKE '%Real Madrid%' AND at.name ILIKE '%Betis%')
            )
        )
  );