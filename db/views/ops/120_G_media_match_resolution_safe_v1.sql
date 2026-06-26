/*
MATCHMATRIX SQL 120_G Media Match Resolution Safe V1

CO TO JE:
- Bezpečnější resolver article -> match.
- Nehledá týmy v celé tabulce public.teams.
- Hledá pouze zápasy ze stejné ligy jako článek.

K ČEMU TO JE:
- Odstraní falešné zásahy typu Start, West, Real, Paris, Aris.
- Připraví pouze reálné kandidáty article -> match.

KDE TO UVIDÍME:
- OPS / Media Command Center / Match Context Engine.

JAK SE TO VYUŽIJE:
- Další krok bude vybrat 1 nejlepší match_id pro článek.
*/

CREATE OR REPLACE VIEW ops.v_media_match_resolution_safe_v1 AS
SELECT
    a.id AS article_id,
    a.title,
    a.published_at,
    alm.league_id AS article_league_id,
    l.name AS article_league_name,

    m.id AS match_id,
    m.kickoff,
    m.status,
    ht.name AS home_team,
    at.name AS away_team,
    m.season,
    m.ext_source,
    m.ext_match_id,

    CASE
        WHEN a.title ILIKE '%' || ht.name || '%'
         AND a.title ILIKE '%' || at.name || '%'
        THEN 100

        WHEN a.title ILIKE '%Barcelona%'
         AND a.title ILIKE '%Real Madrid%'
         AND (
              (ht.name ILIKE '%Barcelona%' AND at.name ILIKE '%Real Madrid%')
           OR (ht.name ILIKE '%Real Madrid%' AND at.name ILIKE '%Barcelona%')
         )
        THEN 95

        WHEN a.title ILIKE '%Betis%'
         AND a.title ILIKE '%Real Madrid%'
         AND (
              (ht.name ILIKE '%Betis%' AND at.name ILIKE '%Real Madrid%')
           OR (ht.name ILIKE '%Real Madrid%' AND at.name ILIKE '%Betis%')
         )
        THEN 95

        ELSE 0
    END AS match_resolution_score,

    CASE
        WHEN m.ext_source = 'football_data' THEN 100
        WHEN m.ext_source = 'api_football' THEN 90
        WHEN m.ext_source = 'football_data_uk' THEN 70
        ELSE 50
    END AS provider_priority,

    now() AS audited_at

FROM public.articles a
JOIN public.article_league_map alm
    ON alm.article_id = a.id
JOIN public.leagues l
    ON l.id = alm.league_id
JOIN public.matches m
    ON m.league_id = alm.league_id
JOIN public.teams ht
    ON ht.id = m.home_team_id
JOIN public.teams at
    ON at.id = m.away_team_id
LEFT JOIN public.article_match_map amm
    ON amm.article_id = a.id
WHERE amm.article_id IS NULL
  AND (
        a.title ILIKE '% vs %'
     OR a.title ILIKE '% v %'
     OR a.title ILIKE '%lineup%'
     OR a.title ILIKE '%lineups%'
     OR a.title ILIKE '%where to watch%'
     OR a.title ILIKE '%matchday%'
  )
  AND m.kickoff BETWEEN a.published_at - INTERVAL '30 days'
                    AND a.published_at + INTERVAL '30 days'
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