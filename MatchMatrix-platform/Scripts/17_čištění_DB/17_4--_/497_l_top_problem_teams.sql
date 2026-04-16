-- 497_l_top_problem_teams.sql
-- Cíl:
-- najít týmy, které se nejčastěji objevují v PAIR_MISSING

WITH src AS (
    SELECT
        u.league_name,
        u.home_normalized,
        u.away_normalized
    FROM public.unmatched_theodds u
    WHERE u.issue_code = 'NO_MATCH_ID'
),
league_map AS (
    SELECT
        s.*,
        l.id AS league_id
    FROM src s
    LEFT JOIN public.leagues l
      ON LOWER(l.theodds_key) = LOWER(s.league_name)
),
team_map AS (
    SELECT
        lm.*,
        ha.team_id AS home_team_id,
        aa.team_id AS away_team_id
    FROM league_map lm
    LEFT JOIN public.team_aliases ha
      ON LOWER(ha.alias) = LOWER(lm.home_normalized)
    LEFT JOIN public.team_aliases aa
      ON LOWER(aa.alias) = LOWER(lm.away_normalized)
),
pairs AS (
    SELECT
        tm.*,
        (
            SELECT COUNT(*)
            FROM public.matches m
            WHERE m.league_id = tm.league_id
              AND (
                    (m.home_team_id = tm.home_team_id AND m.away_team_id = tm.away_team_id)
                 OR (m.home_team_id = tm.away_team_id AND m.away_team_id = tm.home_team_id)
              )
        ) AS pair_matches_anytime
    FROM team_map tm
    WHERE tm.league_id IS NOT NULL
      AND tm.home_team_id IS NOT NULL
      AND tm.away_team_id IS NOT NULL
),
pair_missing AS (
    SELECT *
    FROM pairs
    WHERE COALESCE(pair_matches_anytime, 0) = 0
),
all_teams AS (
    SELECT home_team_id AS team_id FROM pair_missing
    UNION ALL
    SELECT away_team_id FROM pair_missing
)
SELECT
    t.id,
    t.name,
    COUNT(*) AS occurrences
FROM all_teams at
JOIN public.teams t ON t.id = at.team_id
GROUP BY t.id, t.name
ORDER BY occurrences DESC, t.name;