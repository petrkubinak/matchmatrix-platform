-- 545_b_epl_6_cases_detail.sql
-- Cíl:
-- rozebrat 6 konkrétních EPL NO_MATCH_ID případů z run 185
-- bez závislosti na public.unmatched_theodds audit tabulce

WITH epl_cases AS (
    SELECT *
    FROM (
        VALUES
            ('Burnley', 'Brighton and Hove Albion', TIMESTAMP '2026-04-11 14:00:00', 60, 11917),
            ('Crystal Palace', 'Newcastle United',     TIMESTAMP '2026-04-12 13:00:00', 63, 11904),
            ('Manchester United', 'Leeds United',      TIMESTAMP '2026-04-13 19:00:00', 55, 956),
            ('Leeds United', 'Wolverhampton Wanderers',TIMESTAMP '2026-04-18 14:00:00', 956, 59),
            ('Newcastle United', 'Bournemouth',        TIMESTAMP '2026-04-18 14:00:00', 11904, 67),
            ('Tottenham Hotspur', 'Brighton and Hove Albion', TIMESTAMP '2026-04-18 16:30:00', 58, 11917)
    ) AS t(home_raw, away_raw, commence_time, home_team_id, away_team_id)
),

same_exact_pair AS (
    SELECT
        c.home_raw,
        c.away_raw,
        c.commence_time,
        m.id AS match_id,
        l.name AS league_name,
        m.kickoff,
        ht.name AS db_home,
        at.name AS db_away,
        CASE
            WHEN m.home_team_id = c.home_team_id AND m.away_team_id = c.away_team_id THEN 'SAME_DIRECTION'
            WHEN m.home_team_id = c.away_team_id AND m.away_team_id = c.home_team_id THEN 'REVERSED_DIRECTION'
            ELSE 'OTHER'
        END AS pair_relation
    FROM epl_cases c
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
),

nearby_team_usage AS (
    SELECT
        c.home_raw,
        c.away_raw,
        c.commence_time,
        m.id AS match_id,
        l.name AS league_name,
        m.kickoff,
        ht.name AS db_home,
        at.name AS db_away,
        abs(EXTRACT(EPOCH FROM (m.kickoff - c.commence_time))) / 3600.0 AS diff_hours
    FROM epl_cases c
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
    WHERE m.kickoff BETWEEN c.commence_time - INTERVAL '3 days'
                       AND c.commence_time + INTERVAL '3 days'
),

team_lookup AS (
    SELECT
        c.home_raw,
        c.away_raw,
        c.commence_time,
        c.home_team_id,
        c.away_team_id,
        th.name AS home_db_name,
        ta.name AS away_db_name
    FROM epl_cases c
    LEFT JOIN public.teams th
      ON th.id = c.home_team_id
    LEFT JOIN public.teams ta
      ON ta.id = c.away_team_id
)

SELECT
    c.home_raw,
    c.away_raw,
    c.commence_time,
    c.home_team_id,
    c.away_team_id,
    tl.home_db_name,
    tl.away_db_name,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM same_exact_pair p
            WHERE p.home_raw = c.home_raw
              AND p.away_raw = c.away_raw
              AND p.commence_time = c.commence_time
              AND p.league_name = 'Premier League'
        ) THEN 'PAIR_EXISTS_IN_EPL'

        WHEN EXISTS (
            SELECT 1
            FROM same_exact_pair p
            WHERE p.home_raw = c.home_raw
              AND p.away_raw = c.away_raw
              AND p.commence_time = c.commence_time
              AND p.league_name <> 'Premier League'
        ) THEN 'PAIR_EXISTS_IN_OTHER_LEAGUE'

        WHEN EXISTS (
            SELECT 1
            FROM nearby_team_usage n
            WHERE n.home_raw = c.home_raw
              AND n.away_raw = c.away_raw
              AND n.commence_time = c.commence_time
        ) THEN 'TEAM_BRANCH_OR_TIME_DETAIL'

        ELSE 'LIKELY_MISSING_FIXTURE'
    END AS diagnosis
FROM epl_cases c
LEFT JOIN team_lookup tl
  ON tl.home_raw = c.home_raw
 AND tl.away_raw = c.away_raw
 AND tl.commence_time = c.commence_time
ORDER BY c.commence_time, c.home_raw, c.away_raw;

-- DETAIL A: existuje stejný pár někde v DB?
SELECT
    p.home_raw,
    p.away_raw,
    p.commence_time,
    p.match_id,
    p.league_name,
    p.kickoff,
    p.db_home,
    p.db_away,
    p.pair_relation
FROM same_exact_pair p
ORDER BY p.home_raw, p.away_raw, p.kickoff;

-- DETAIL B: jak se ty týmy používají kolem stejného času?
SELECT
    n.home_raw,
    n.away_raw,
    n.commence_time,
    n.match_id,
    n.league_name,
    n.kickoff,
    n.db_home,
    n.db_away,
    ROUND(n.diff_hours::numeric, 2) AS diff_hours
FROM nearby_team_usage n
ORDER BY n.home_raw, n.away_raw, n.diff_hours, n.kickoff;