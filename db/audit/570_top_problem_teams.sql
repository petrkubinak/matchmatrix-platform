-- =====================================================================
-- 570_top_problem_teams.sql
-- Účel:
-- Najít TOP problematické týmy z TheOdds NO_MATCH_ID backlogu
-- =====================================================================
-- =====================================================================
-- 570_top_problem_teams.sql
-- Účel:
-- Najít TOP problematické týmy z public.unmatched_theodds
-- =====================================================================

WITH teams AS (
    SELECT
        lower(btrim(home_raw)) AS team_name,
        COUNT(*) AS cnt
    FROM public.unmatched_theodds
    WHERE coalesce(btrim(home_raw), '') <> ''
    GROUP BY lower(btrim(home_raw))

    UNION ALL

    SELECT
        lower(btrim(away_raw)) AS team_name,
        COUNT(*) AS cnt
    FROM public.unmatched_theodds
    WHERE coalesce(btrim(away_raw), '') <> ''
    GROUP BY lower(btrim(away_raw))
),
agg AS (
    SELECT
        team_name,
        SUM(cnt) AS total_occurrences
    FROM teams
    GROUP BY team_name
)
SELECT
    team_name,
    total_occurrences
FROM agg
ORDER BY total_occurrences DESC, team_name
LIMIT 20;