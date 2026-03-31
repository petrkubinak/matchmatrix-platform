-- MatchMatrix
-- Audit: odds coverage pro budoucí zápasy + 1/X/2/1X/12/X2
-- Spouštět v DBeaveru

-- =========================================================
-- 1) Přehled coverage budoucích zápasů po ligách
-- =========================================================
WITH future_matches AS (
    SELECT
        m.id AS match_id,
        m.kickoff,
        l.id AS league_id,
        l.name AS league_name,
        sp.code AS sport_code
    FROM public.matches m
    JOIN public.leagues l
      ON l.id = m.league_id
    LEFT JOIN public.sports sp
      ON sp.id = l.sport_id
    WHERE m.kickoff >= now()
      AND m.kickoff < now() + interval '14 days'
),
odds_codes AS (
    SELECT
        o.match_id,
        mo.code
    FROM public.odds o
    JOIN public.market_outcomes mo
      ON mo.id = o.market_outcome_id
    WHERE mo.code IN ('1','X','2','1X','12','X2')
    GROUP BY o.match_id, mo.code
),
coverage AS (
    SELECT
        fm.sport_code,
        fm.league_id,
        fm.league_name,
        COUNT(*) AS matches_total,
        COUNT(*) FILTER (
            WHERE EXISTS (
                SELECT 1
                FROM odds_codes oc
                WHERE oc.match_id = fm.match_id
                  AND oc.code = '1'
            )
        ) AS matches_with_1,
        COUNT(*) FILTER (
            WHERE EXISTS (
                SELECT 1
                FROM odds_codes oc
                WHERE oc.match_id = fm.match_id
                  AND oc.code = 'X'
            )
        ) AS matches_with_x,
        COUNT(*) FILTER (
            WHERE EXISTS (
                SELECT 1
                FROM odds_codes oc
                WHERE oc.match_id = fm.match_id
                  AND oc.code = '2'
            )
        ) AS matches_with_2,
        COUNT(*) FILTER (
            WHERE EXISTS (
                SELECT 1
                FROM odds_codes oc
                WHERE oc.match_id = fm.match_id
                  AND oc.code = '1X'
            )
        ) AS matches_with_1x,
        COUNT(*) FILTER (
            WHERE EXISTS (
                SELECT 1
                FROM odds_codes oc
                WHERE oc.match_id = fm.match_id
                  AND oc.code = '12'
            )
        ) AS matches_with_12,
        COUNT(*) FILTER (
            WHERE EXISTS (
                SELECT 1
                FROM odds_codes oc
                WHERE oc.match_id = fm.match_id
                  AND oc.code = 'X2'
            )
        ) AS matches_with_x2
    FROM future_matches fm
    GROUP BY
        fm.sport_code,
        fm.league_id,
        fm.league_name
)
SELECT
    sport_code,
    league_id,
    league_name,
    matches_total,
    matches_with_1,
    matches_with_x,
    matches_with_2,
    matches_with_1x,
    matches_with_12,
    matches_with_x2
FROM coverage
ORDER BY sport_code, league_name;

-- =========================================================
-- 2) Konkrétní budoucí zápasy bez jakýchkoliv odds
-- =========================================================
WITH future_matches AS (
    SELECT
        m.id AS match_id,
        m.kickoff,
        l.name AS league_name,
        ht.name AS home_team,
        at.name AS away_team
    FROM public.matches m
    LEFT JOIN public.leagues l
      ON l.id = m.league_id
    LEFT JOIN public.teams ht
      ON ht.id = m.home_team_id
    LEFT JOIN public.teams at
      ON at.id = m.away_team_id
    WHERE m.kickoff >= now()
      AND m.kickoff < now() + interval '14 days'
)
SELECT
    fm.match_id,
    fm.kickoff,
    fm.league_name,
    fm.home_team,
    fm.away_team
FROM future_matches fm
WHERE NOT EXISTS (
    SELECT 1
    FROM public.odds o
    WHERE o.match_id = fm.match_id
)
ORDER BY fm.kickoff, fm.match_id;

-- =========================================================
-- 3) Zápasy, které mají 1/X/2, ale nemají 1X/12/X2
-- =========================================================
WITH match_codes AS (
    SELECT
        o.match_id,
        MAX(CASE WHEN mo.code = '1'  THEN 1 ELSE 0 END) AS has_1,
        MAX(CASE WHEN mo.code = 'X'  THEN 1 ELSE 0 END) AS has_x,
        MAX(CASE WHEN mo.code = '2'  THEN 1 ELSE 0 END) AS has_2,
        MAX(CASE WHEN mo.code = '1X' THEN 1 ELSE 0 END) AS has_1x,
        MAX(CASE WHEN mo.code = '12' THEN 1 ELSE 0 END) AS has_12,
        MAX(CASE WHEN mo.code = 'X2' THEN 1 ELSE 0 END) AS has_x2
    FROM public.odds o
    JOIN public.market_outcomes mo
      ON mo.id = o.market_outcome_id
    GROUP BY o.match_id
)
SELECT
    m.id AS match_id,
    m.kickoff,
    l.name AS league_name,
    ht.name AS home_team,
    at.name AS away_team,
    mc.has_1,
    mc.has_x,
    mc.has_2,
    mc.has_1x,
    mc.has_12,
    mc.has_x2
FROM match_codes mc
JOIN public.matches m
  ON m.id = mc.match_id
LEFT JOIN public.leagues l
  ON l.id = m.league_id
LEFT JOIN public.teams ht
  ON ht.id = m.home_team_id
LEFT JOIN public.teams at
  ON at.id = m.away_team_id
WHERE m.kickoff >= now()
  AND m.kickoff < now() + interval '14 days'
  AND mc.has_1 = 1
  AND mc.has_x = 1
  AND mc.has_2 = 1
  AND (mc.has_1x = 0 OR mc.has_12 = 0 OR mc.has_x2 = 0)
ORDER BY m.kickoff, m.id;