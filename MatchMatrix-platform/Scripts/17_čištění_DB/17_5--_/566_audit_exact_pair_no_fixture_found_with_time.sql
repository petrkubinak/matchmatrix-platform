-- ============================================================
-- 566_audit_exact_pair_no_fixture_found_with_time.sql
-- MatchMatrix / TheOdds
--
-- Audit NO_MATCH_ID případů s kontrolou časové blízkosti
-- proti public.matches
--
-- Tabulka:
--   public.unmatched_theodds
-- ============================================================

WITH last_theodds_runs AS (
    SELECT id
    FROM public.api_import_runs
    WHERE source = 'theodds'
    ORDER BY id DESC
    LIMIT 5
),

raw_events AS (
    SELECT
        r.run_id,
        (r.payload ->> 'sport_key')::text AS league_name,
        ev ->> 'home_team' AS home_raw,
        ev ->> 'away_team' AS away_raw,
        (ev ->> 'commence_time')::timestamptz AS provider_kickoff
    FROM public.api_raw_payloads r
    CROSS JOIN LATERAL jsonb_array_elements(r.payload -> 'payload') ev
    WHERE r.source = 'theodds'
      AND r.run_id IN (SELECT id FROM last_theodds_runs)
      AND jsonb_typeof(r.payload -> 'payload') = 'array'
),

src AS (
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
        u.issue_code,
        re.provider_kickoff
    FROM public.unmatched_theodds u
    LEFT JOIN raw_events re
           ON re.league_name = u.league_name
          AND re.home_raw = u.home_raw
          AND re.away_raw = u.away_raw
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
        l.name AS db_league_name,
        l.theodds_key,
        m.kickoff,
        m.ext_source,
        m.ext_match_id,
        ABS(EXTRACT(EPOCH FROM (m.kickoff::timestamptz - s.provider_kickoff))) / 3600.0 AS diff_hours
    FROM src2 s
    JOIN public.matches m
      ON m.home_team_id = s.home_team_id
     AND m.away_team_id = s.away_team_id
    LEFT JOIN public.leagues l
      ON l.id = m.league_id
    WHERE s.provider_kickoff IS NOT NULL
),

pair_same_league AS (
    SELECT
        p.src_row_id,
        p.db_match_id,
        p.db_league_name,
        p.theodds_key,
        p.kickoff,
        p.ext_source,
        p.ext_match_id,
        p.diff_hours
    FROM pair_all p
    JOIN src2 s
      ON s.src_row_id = p.src_row_id
    WHERE p.theodds_key = s.league_name
),

best_same_league AS (
    SELECT DISTINCT ON (psl.src_row_id)
        psl.src_row_id,
        psl.db_match_id,
        psl.db_league_name,
        psl.theodds_key,
        psl.kickoff,
        psl.ext_source,
        psl.ext_match_id,
        psl.diff_hours
    FROM pair_same_league psl
    ORDER BY psl.src_row_id, psl.diff_hours ASC, psl.db_match_id
),

best_any AS (
    SELECT DISTINCT ON (pa.src_row_id)
        pa.src_row_id,
        pa.db_match_id,
        pa.db_league_name,
        pa.theodds_key,
        pa.kickoff,
        pa.ext_source,
        pa.ext_match_id,
        pa.diff_hours
    FROM pair_all pa
    ORDER BY pa.src_row_id, pa.diff_hours ASC, pa.db_match_id
)

SELECT
    s.src_row_id,
    s.league_name,
    s.event_name,
    s.home_raw,
    s.away_raw,
    s.provider_kickoff,
    s.home_team_id,
    s.away_team_id,

    bsl.db_match_id AS same_league_match_id,
    bsl.db_league_name AS same_league_db_league,
    bsl.kickoff AS same_league_kickoff,
    ROUND(bsl.diff_hours::numeric, 2) AS same_league_diff_hours,

    ba.db_match_id AS any_match_id,
    ba.db_league_name AS any_db_league,
    ba.theodds_key AS any_theodds_key,
    ba.kickoff AS any_kickoff,
    ROUND(ba.diff_hours::numeric, 2) AS any_diff_hours,

    CASE
        WHEN bsl.db_match_id IS NOT NULL AND bsl.diff_hours <= 6
            THEN 'SHOULD_HAVE_ATTACHED_STRICT'
        WHEN bsl.db_match_id IS NOT NULL AND bsl.diff_hours <= 72
            THEN 'SHOULD_HAVE_ATTACHED_TOLERANCE'
        WHEN bsl.db_match_id IS NOT NULL
            THEN 'SAME_LEAGUE_PAIR_EXISTS_BUT_OUTSIDE_TIME_WINDOW'
        WHEN ba.db_match_id IS NOT NULL AND ba.diff_hours <= 72
            THEN 'PAIR_EXISTS_OTHER_LEAGUE_WITHIN_TIME_WINDOW'
        WHEN ba.db_match_id IS NOT NULL
            THEN 'PAIR_EXISTS_ONLY_HISTORICALLY'
        WHEN s.provider_kickoff IS NULL
            THEN 'RAW_KICKOFF_NOT_FOUND'
        ELSE 'MISSING_FIXTURE_IN_PUBLIC_MATCHES'
    END AS audit_result

FROM src2 s
LEFT JOIN best_same_league bsl
       ON bsl.src_row_id = s.src_row_id
LEFT JOIN best_any ba
       ON ba.src_row_id = s.src_row_id
ORDER BY s.league_name, s.event_name;