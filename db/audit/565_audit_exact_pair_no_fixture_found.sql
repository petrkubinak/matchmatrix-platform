-- ============================================================
-- 565_audit_exact_pair_no_fixture_found.sql
-- MatchMatrix / TheOdds
--
-- Verze pro tabulku:
--   public.unmatched_theodds
--
-- POZN:
-- Importovaná tabulka nemá attach_reason ani kickoff.
-- Audit tedy jede nad issue_code = 'NO_MATCH_ID'
-- a porovnává exact pair proti public.matches.
-- ============================================================

WITH src AS (
    SELECT
        row_number() OVER () AS src_row_id,
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
src2 AS (
    SELECT
        s.*,
        pth.canonical_team_id AS home_team_id,
        pta.canonical_team_id AS away_team_id
    FROM src s
    LEFT JOIN public.v_preferred_team_name_lookup pth
           ON pth.team_name_key = s.home_normalized
    LEFT JOIN public.v_preferred_team_name_lookup pta
           ON pta.team_name_key = s.away_normalized
),
pair_all AS (
    SELECT
        s.src_row_id,
        m.id AS db_match_id,
        m.league_id,
        l.name AS db_league_name,
        l.theodds_key,
        m.kickoff,
        m.ext_source,
        m.ext_match_id
    FROM src2 s
    JOIN public.matches m
      ON m.home_team_id = s.home_team_id
     AND m.away_team_id = s.away_team_id
    LEFT JOIN public.leagues l
      ON l.id = m.league_id
),
pair_same_league AS (
    SELECT
        p.*
    FROM pair_all p
    JOIN src2 s
      ON s.src_row_id = p.src_row_id
    WHERE p.theodds_key = s.league_name
),
best_any AS (
    SELECT DISTINCT ON (src_row_id)
        src_row_id,
        db_match_id,
        league_id,
        db_league_name,
        theodds_key,
        kickoff,
        ext_source,
        ext_match_id
    FROM pair_all
    ORDER BY src_row_id, kickoff, db_match_id
),
best_same_league AS (
    SELECT DISTINCT ON (src_row_id)
        src_row_id,
        db_match_id,
        league_id,
        db_league_name,
        theodds_key,
        kickoff,
        ext_source,
        ext_match_id
    FROM pair_same_league
    ORDER BY src_row_id, kickoff, db_match_id
)
SELECT
    s.src_row_id,
    s.league_name,
    s.event_name,
    s.home_raw,
    s.away_raw,
    s.home_team_id,
    s.away_team_id,
    s.issue_code,

    CASE
        WHEN bsl.db_match_id IS NOT NULL THEN 'PAIR_EXISTS_SAME_LEAGUE'
        WHEN ba.db_match_id  IS NOT NULL THEN 'PAIR_EXISTS_OTHER_LEAGUE'
        ELSE 'PAIR_NOT_FOUND_ANYWHERE'
    END AS pair_presence_status,

    bsl.db_match_id      AS same_league_match_id,
    bsl.db_league_name   AS same_league_db_league,
    bsl.kickoff          AS same_league_kickoff,
    bsl.ext_source       AS same_league_ext_source,
    bsl.ext_match_id     AS same_league_ext_match_id,

    ba.db_match_id       AS any_match_id,
    ba.db_league_name    AS any_db_league,
    ba.theodds_key       AS any_theodds_key,
    ba.kickoff           AS any_kickoff,
    ba.ext_source        AS any_ext_source,
    ba.ext_match_id      AS any_ext_match_id,

    CASE
        WHEN bsl.db_match_id IS NOT NULL THEN 'PAIR_EXISTS_IN_SAME_LEAGUE'
        WHEN ba.db_match_id IS NOT NULL THEN 'PAIR_EXISTS_BUT_IN_OTHER_LEAGUE'
        ELSE 'MISSING_FIXTURE_IN_PUBLIC_MATCHES'
    END AS audit_result

FROM src2 s
LEFT JOIN best_same_league bsl
       ON bsl.src_row_id = s.src_row_id
LEFT JOIN best_any ba
       ON ba.src_row_id = s.src_row_id
ORDER BY
    s.league_name,
    s.event_name;