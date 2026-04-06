-- 549_verify_epl_after_leeds_brighton_merge.sql
-- Cíl:
-- ověřit, že po merge Leeds/Brighton spadly EPL problem cases

-- 1) Přesný check 6 původních EPL případů proti current DB
WITH epl_cases AS (
    SELECT *
    FROM (
        VALUES
            ('Burnley', 'Brighton and Hove Albion', TIMESTAMP '2026-04-11 14:00:00', 60, 64),
            ('Crystal Palace', 'Newcastle United',     TIMESTAMP '2026-04-12 13:00:00', 63, 11904),
            ('Manchester United', 'Leeds United',      TIMESTAMP '2026-04-13 19:00:00', 55, 61),
            ('Leeds United', 'Wolverhampton Wanderers',TIMESTAMP '2026-04-18 14:00:00', 61, 59),
            ('Newcastle United', 'Bournemouth',        TIMESTAMP '2026-04-18 14:00:00', 11904, 67),
            ('Tottenham Hotspur', 'Brighton and Hove Albion', TIMESTAMP '2026-04-18 16:30:00', 58, 64)
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
    at.name AS db_away
FROM epl_cases c
LEFT JOIN public.matches m
  ON m.home_team_id = c.home_team_id
 AND m.away_team_id = c.away_team_id
 AND m.kickoff = c.commence_time
LEFT JOIN public.leagues l
  ON l.id = m.league_id
LEFT JOIN public.teams ht
  ON ht.id = m.home_team_id
LEFT JOIN public.teams at
  ON at.id = m.away_team_id
ORDER BY c.commence_time, c.home_raw, c.away_raw;

-- 2) Ověření, že staré team větve už neexistují
SELECT id, name
FROM public.teams
WHERE id IN (956, 11917, 61, 64)
ORDER BY id;

-- 3) Alias check
SELECT
    ta.team_id,
    t.name AS team_name,
    ta.alias,
    ta.source
FROM public.team_aliases ta
JOIN public.teams t
  ON t.id = ta.team_id
WHERE ta.team_id IN (61, 64)
  AND lower(ta.alias) IN (
      lower('Leeds'),
      lower('Leeds United'),
      lower('Brighton'),
      lower('Brighton and Hove Albion')
  )
ORDER BY ta.team_id, ta.alias;