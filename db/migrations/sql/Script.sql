WITH src AS (
    SELECT
        u.provider,
        u.league_name,
        u.event_name,
        u.home_raw,
        u.away_raw,
        u.home_normalized,
        u.away_normalized,
        u.best_home_candidate,
        u.best_away_candidate,
        u.best_home_score,
        u.best_away_score,
        u.match_id,
        u.issue_code
    FROM public.unmatched_theodds u
    WHERE u.issue_code = 'NO_MATCH_ID'
),
league_map AS (
    SELECT
        s.*,
        l.id   AS league_id,
        l.name AS canonical_league_name,
        l.theodds_key
    FROM src s
    LEFT JOIN public.leagues l
        ON LOWER(l.theodds_key) = LOWER(s.league_name)
),
team_map AS (
    SELECT
        lm.*,
        tha.team_id AS home_team_id,
        taa.team_id AS away_team_id
    FROM league_map lm
    LEFT JOIN public.team_aliases tha
        ON LOWER(tha.alias) = LOWER(lm.home_normalized)
    LEFT JOIN public.team_aliases taa
        ON LOWER(taa.alias) = LOWER(lm.away_normalized)
),
coverage AS (
    SELECT
        tm.*,
        (
            SELECT COUNT(*)
            FROM public.matches m
            WHERE m.league_id = tm.league_id
        ) AS matches_all,
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
)
SELECT
    CASE
        WHEN league_id IS NULL THEN 'LEAGUE_NOT_MAPPED'
        WHEN home_team_id IS NULL OR away_team_id IS NULL THEN 'TEAM_NOT_MAPPED'
        WHEN COALESCE(matches_all, 0) = 0 THEN 'NO_LEAGUE_COVERAGE'
        WHEN COALESCE(pair_matches_anytime, 0) = 0 THEN 'PAIR_MISSING_IN_EXISTING_LEAGUE'
        ELSE 'CHECK_DETAIL'
    END AS coverage_bucket,
    COUNT(*) AS rows_count
FROM coverage
GROUP BY 1
ORDER BY rows_count DESC, coverage_bucket;