-- 561_brasileirao_exact_pair_check.sql
-- Cíl:
-- přesně ověřit pair existenci pro 2 zbývající Brasileirão případy

WITH cases AS (
    SELECT *
    FROM (
        VALUES
            ('Chapecoense', 'Vitoria', TIMESTAMP '2026-04-06 21:30:00', 11, 16),
            ('Palmeiras', 'Grêmio',   TIMESTAMP '2026-04-06 21:30:00', 8, 6)
    ) AS t(home_raw, away_raw, commence_time, home_team_id, away_team_id)
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
    at.name AS db_away,
    CASE
        WHEN m.home_team_id = c.home_team_id AND m.away_team_id = c.away_team_id THEN 'SAME_DIRECTION'
        WHEN m.home_team_id = c.away_team_id AND m.away_team_id = c.home_team_id THEN 'REVERSED_DIRECTION'
        ELSE 'OTHER'
    END AS pair_relation,
    ROUND(CAST(ABS(EXTRACT(EPOCH FROM (m.kickoff - c.commence_time))) / 3600.0 AS numeric), 2) AS diff_hours
FROM cases c
LEFT JOIN public.matches m
  ON (
       (m.home_team_id = c.home_team_id AND m.away_team_id = c.away_team_id)
    OR (m.home_team_id = c.away_team_id AND m.away_team_id = c.home_team_id)
  )
LEFT JOIN public.leagues l
  ON l.id = m.league_id
LEFT JOIN public.teams ht
  ON ht.id = m.home_team_id
LEFT JOIN public.teams at
  ON at.id = m.away_team_id
ORDER BY c.home_raw, c.away_raw, m.kickoff;