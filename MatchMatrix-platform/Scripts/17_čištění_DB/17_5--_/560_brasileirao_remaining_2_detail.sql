-- 560_brasileirao_remaining_2_detail.sql
-- Cíl:
-- detailně rozebrat 2 zbývající Campeonato Brasileiro Série A pair-missing případy

WITH cases AS (
    SELECT *
    FROM (
        VALUES
            ('Palmeiras', 'Grêmio', TIMESTAMP '2026-04-06 21:30:00'),
            ('Chapecoense', 'Vitoria', TIMESTAMP '2026-04-06 21:30:00')
    ) AS t(home_raw, away_raw, commence_time)
)

SELECT
    c.home_raw,
    c.away_raw,
    c.commence_time,
    m.id AS match_id,
    l.name AS league_name,
    m.kickoff,
    ht.id AS db_home_team_id,
    ht.name AS db_home,
    at.id AS db_away_team_id,
    at.name AS db_away
FROM cases c
LEFT JOIN public.matches m
  ON m.kickoff BETWEEN c.commence_time - INTERVAL '3 days'
                   AND c.commence_time + INTERVAL '3 days'
LEFT JOIN public.leagues l
  ON l.id = m.league_id
LEFT JOIN public.teams ht
  ON ht.id = m.home_team_id
LEFT JOIN public.teams at
  ON at.id = m.away_team_id
WHERE l.name = 'Campeonato Brasileiro Série A'
ORDER BY c.home_raw, c.away_raw, m.kickoff;