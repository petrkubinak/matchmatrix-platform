-- 496_audit_missing_fixture_coverage_FIX.sql
-- FIX: unmatched_theodds nemá ID ani FK → mapujeme přes názvy

WITH src AS (
    SELECT
        u.provider,
        u.league_name,
        u.home_normalized,
        u.away_normalized,
        u.match_id,
        u.issue_code
    FROM public.unmatched_theodds u
    WHERE COALESCE(u.issue_code, 'missing_fixture') = 'missing_fixture'
),

-- =========================================================
-- MAPOVÁNÍ NA CANONICAL LEAGUE
-- =========================================================
league_map AS (
    SELECT
        s.*,
        l.id   AS league_id,
        l.name AS league_name_canonical
    FROM src s
    LEFT JOIN public.leagues l
        ON LOWER(l.name) = LOWER(s.league_name)
),

-- =========================================================
-- MAPOVÁNÍ NA TEAMY
-- =========================================================
team_map AS (
    SELECT
        lm.*,

        th.team_id AS home_team_id,
        ta.team_id AS away_team_id

    FROM league_map lm

    LEFT JOIN public.team_aliases th
        ON LOWER(th.alias) = LOWER(lm.home_normalized)

    LEFT JOIN public.team_aliases ta
        ON LOWER(ta.alias) = LOWER(lm.away_normalized)
),

-- =========================================================
-- COVERAGE
-- =========================================================
coverage AS (
    SELECT
        tm.*,

        -- existuje liga v matches?
        (
            SELECT COUNT(*)
            FROM public.matches m
            WHERE m.league_id = tm.league_id
        ) AS matches_all,

        -- existuje pár týmů?
        (
            SELECT COUNT(*)
            FROM public.matches m
            WHERE m.league_id = tm.league_id
              AND (
                    (m.home_team_id = tm.home_team_id AND m.away_team_id = tm.away_team_id)
                 OR (m.home_team_id = tm.away_team_id AND m.away_team_id = tm.home_team_id)
              )
        ) AS pair_matches

    FROM team_map tm
)

SELECT
    league_name,
    league_name_canonical,
    home_normalized,
    away_normalized,

    matches_all,
    pair_matches,

    CASE
        WHEN league_id IS NULL THEN 'LEAGUE_NOT_MAPPED'
        WHEN home_team_id IS NULL OR away_team_id IS NULL THEN 'TEAM_NOT_MAPPED'
        WHEN COALESCE(matches_all, 0) = 0 THEN 'NO_LEAGUE_COVERAGE'
        WHEN COALESCE(pair_matches, 0) = 0 THEN 'PAIR_MISSING'
        ELSE 'CHECK_DETAIL'
    END AS coverage_bucket

FROM coverage
ORDER BY coverage_bucket, league_name;