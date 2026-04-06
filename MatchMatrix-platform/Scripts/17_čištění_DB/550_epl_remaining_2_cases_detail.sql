-- 550_epl_remaining_2_cases_detail.sql
-- Cíl:
-- rozebrat poslední 2 zbývající EPL případy:
--   Crystal Palace vs Newcastle United
--   Newcastle United vs Bournemouth

WITH cases AS (
    SELECT *
    FROM (
        VALUES
            ('Crystal Palace', 'Newcastle United', TIMESTAMP '2026-04-12 13:00:00', 63, 11904),
            ('Newcastle United', 'Bournemouth',    TIMESTAMP '2026-04-18 14:00:00', 11904, 67)
    ) AS t(home_raw, away_raw, commence_time, home_team_id, away_team_id)
)

-- 1) Přesné páry kdekoliv v DB
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
    END AS pair_relation
FROM cases c
JOIN public.matches m
  ON (
       (m.home_team_id = c.home_team_id AND m.away_team_id = c.away_team_id)
    OR (m.home_team_id = c.away_team_id AND m.away_team_id = c.home_team_id)
  )
JOIN public.leagues l
  ON l.id = m.league_id
JOIN public.teams ht
  ON ht.id = m.home_team_id
JOIN public.teams at
  ON at.id = m.away_team_id
ORDER BY c.home_raw, c.away_raw, m.kickoff;

-- 2) Všechny zápasy těchto týmů v okně +- 5 dnů
WITH cases AS (
    SELECT *
    FROM (
        VALUES
            ('Crystal Palace', 'Newcastle United', TIMESTAMP '2026-04-12 13:00:00', 63, 11904),
            ('Newcastle United', 'Bournemouth',    TIMESTAMP '2026-04-18 14:00:00', 11904, 67)
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
    ROUND(CAST(ABS(EXTRACT(EPOCH FROM (m.kickoff - c.commence_time))) / 3600.0 AS numeric), 2) AS diff_hours
FROM cases c
JOIN public.matches m
  ON (
       m.home_team_id IN (c.home_team_id, c.away_team_id)
    OR m.away_team_id IN (c.home_team_id, c.away_team_id)
  )
JOIN public.leagues l
  ON l.id = m.league_id
JOIN public.teams ht
  ON ht.id = m.home_team_id
JOIN public.teams at
  ON at.id = m.away_team_id
WHERE m.kickoff BETWEEN c.commence_time - INTERVAL '5 days'
                   AND c.commence_time + INTERVAL '5 days'
ORDER BY c.home_raw, c.away_raw, diff_hours, m.kickoff;

-- 3) Provider map
SELECT
    t.id AS team_id,
    t.name AS team_name,
    tpm.provider,
    tpm.provider_team_id
FROM public.teams t
LEFT JOIN public.team_provider_map tpm
  ON tpm.team_id = t.id
WHERE t.id IN (63, 11904, 67)
ORDER BY t.id, tpm.provider, tpm.provider_team_id;

-- 4) Aliasy
SELECT
    ta.team_id,
    t.name AS team_name,
    ta.alias,
    ta.source
FROM public.team_aliases ta
JOIN public.teams t
  ON t.id = ta.team_id
WHERE ta.team_id IN (63, 11904, 67)
ORDER BY ta.team_id, ta.alias, ta.source;