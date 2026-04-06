-- 562_libertadores_remaining_2_detail.sql
-- Cíl:
-- detailně rozebrat 2 zbývající Copa Libertadores případy

WITH cases AS (
    SELECT *
    FROM (
        VALUES
            ('Rosario Central', 'Independiente del Valle', TIMESTAMP '2026-04-07 22:00:00'),
            ('Cusco FC', 'Flamengo-RJ', TIMESTAMP '2026-04-09 00:30:00')
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
  ON m.kickoff BETWEEN c.commence_time - INTERVAL '5 days'
                   AND c.commence_time + INTERVAL '5 days'
LEFT JOIN public.leagues l
  ON l.id = m.league_id
LEFT JOIN public.teams ht
  ON ht.id = m.home_team_id
LEFT JOIN public.teams at
  ON at.id = m.away_team_id
WHERE l.name = 'Copa Libertadores'
ORDER BY c.home_raw, c.away_raw, m.kickoff;