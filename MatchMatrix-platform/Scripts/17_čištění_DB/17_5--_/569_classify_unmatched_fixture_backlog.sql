-- ============================================================
-- 569_classify_unmatched_fixture_backlog.sql
-- MatchMatrix / TheOdds + Football-Data
--
-- Finální klasifikace unmatched backlogu z public.unmatched_theodds
-- ============================================================

WITH params AS (
    SELECT 192::bigint AS football_data_run_id
),

src AS (
    SELECT
        row_number() OVER () AS src_row_id,
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
        u.issue_code
    FROM public.unmatched_theodds u
    WHERE u.issue_code = 'NO_MATCH_ID'
),

src_map AS (
    SELECT
        s.src_row_id,
        s.league_name,
        s.event_name,
        s.home_raw,
        s.away_raw,
        s.home_normalized,
        s.away_normalized,
        s.best_home_candidate,
        s.best_away_candidate,
        s.best_home_score,
        s.best_away_score,
        s.issue_code,
        pth.canonical_team_id AS home_team_id,
        pta.canonical_team_id AS away_team_id
    FROM src s
    LEFT JOIN public.v_preferred_team_name_lookup pth
           ON pth.team_name_key = s.home_normalized
    LEFT JOIN public.v_preferred_team_name_lookup pta
           ON pta.team_name_key = s.away_normalized
),

raw_base AS (
    SELECT
        arp.run_id,
        arp.endpoint,
        arp.payload,
        CASE
            WHEN jsonb_typeof(arp.payload -> 'payload' -> 'matches') = 'array'
                THEN arp.payload -> 'payload' -> 'matches'
            WHEN jsonb_typeof(arp.payload -> 'matches') = 'array'
                THEN arp.payload -> 'matches'
            ELSE '[]'::jsonb
        END AS matches_json
    FROM public.api_raw_payloads arp
    JOIN params p
      ON p.football_data_run_id = arp.run_id
    WHERE arp.source = 'football_data'
),

raw_matches AS (
    SELECT
        rb.run_id,
        rb.endpoint,
        COALESCE(
            rb.payload -> 'payload' -> 'competition' ->> 'name',
            rb.payload -> 'competition' ->> 'name'
        ) AS competition_name,
        COALESCE(
            m ->> 'utcDate',
            m ->> 'date',
            m ->> 'kickoff'
        ) AS kickoff_raw,
        COALESCE(m ->> 'id', m ->> 'match_id') AS provider_match_id,
        COALESCE(m -> 'homeTeam' ->> 'id', m -> 'home' ->> 'id') AS provider_home_team_id,
        COALESCE(m -> 'awayTeam' ->> 'id', m -> 'away' ->> 'id') AS provider_away_team_id,
        COALESCE(m -> 'homeTeam' ->> 'name', m -> 'home' ->> 'name') AS home_raw,
        COALESCE(m -> 'awayTeam' ->> 'name', m -> 'away' ->> 'name') AS away_raw
    FROM raw_base rb
    CROSS JOIN LATERAL jsonb_array_elements(rb.matches_json) m
),

raw_norm AS (
    SELECT
        rm.run_id,
        rm.endpoint,
        rm.competition_name,
        rm.kickoff_raw,
        rm.provider_match_id,
        rm.provider_home_team_id,
        rm.provider_away_team_id,
        rm.home_raw,
        rm.away_raw,
        lower(btrim(rm.home_raw)) AS home_name_key,
        lower(btrim(rm.away_raw)) AS away_name_key
    FROM raw_matches rm
),

src_norm AS (
    SELECT
        sm.src_row_id,
        sm.league_name,
        sm.event_name,
        sm.home_raw,
        sm.away_raw,
        sm.home_team_id,
        sm.away_team_id,
        sm.issue_code,
        lower(btrim(sm.home_raw)) AS home_name_key,
        lower(btrim(sm.away_raw)) AS away_name_key
    FROM src_map sm
),

raw_hit AS (
    SELECT DISTINCT
        s.src_row_id,
        r.provider_match_id,
        r.kickoff_raw,
        r.endpoint,
        r.competition_name,
        r.provider_home_team_id,
        r.provider_away_team_id,
        r.home_raw AS raw_home_raw,
        r.away_raw AS raw_away_raw
    FROM src_norm s
    JOIN raw_norm r
      ON s.home_name_key = r.home_name_key
     AND s.away_name_key = r.away_name_key
),

db_match_hit AS (
    SELECT DISTINCT
        s.src_row_id,
        m.id AS match_id,
        m.kickoff,
        m.ext_source,
        m.ext_match_id,
        l.id AS league_id,
        l.name AS league_name_db,
        l.theodds_key
    FROM src_map s
    JOIN public.matches m
      ON m.home_team_id = s.home_team_id
     AND m.away_team_id = s.away_team_id
    LEFT JOIN public.leagues l
      ON l.id = m.league_id
),

db_match_same_league AS (
    SELECT
        d.src_row_id,
        d.match_id,
        d.kickoff,
        d.ext_source,
        d.ext_match_id,
        d.league_id,
        d.league_name_db,
        d.theodds_key
    FROM db_match_hit d
    JOIN src_map s
      ON s.src_row_id = d.src_row_id
    WHERE d.theodds_key = s.league_name
),

best_db_same_league AS (
    SELECT DISTINCT ON (dsl.src_row_id)
        dsl.src_row_id,
        dsl.match_id,
        dsl.kickoff,
        dsl.ext_source,
        dsl.ext_match_id,
        dsl.league_id,
        dsl.league_name_db,
        dsl.theodds_key
    FROM db_match_same_league dsl
    ORDER BY dsl.src_row_id, dsl.kickoff DESC NULLS LAST, dsl.match_id DESC
),

best_db_any AS (
    SELECT DISTINCT ON (d.src_row_id)
        d.src_row_id,
        d.match_id,
        d.kickoff,
        d.ext_source,
        d.ext_match_id,
        d.league_id,
        d.league_name_db,
        d.theodds_key
    FROM db_match_hit d
    ORDER BY d.src_row_id, d.kickoff DESC NULLS LAST, d.match_id DESC
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

    rh.provider_match_id AS raw_provider_match_id,
    rh.kickoff_raw AS raw_kickoff,
    rh.endpoint AS raw_endpoint,
    rh.competition_name AS raw_competition_name,

    bsl.match_id AS db_same_league_match_id,
    bsl.kickoff AS db_same_league_kickoff,
    bsl.ext_source AS db_same_league_ext_source,
    bsl.ext_match_id AS db_same_league_ext_match_id,

    bda.match_id AS db_any_match_id,
    bda.kickoff AS db_any_kickoff,
    bda.ext_source AS db_any_ext_source,
    bda.ext_match_id AS db_any_ext_match_id,
    bda.league_name_db AS db_any_league_name,
    bda.theodds_key AS db_any_theodds_key,

    CASE
        WHEN s.home_team_id IS NULL OR s.away_team_id IS NULL
            THEN 'TEAM_MAPPING_INCOMPLETE'

        WHEN rh.provider_match_id IS NOT NULL AND bsl.match_id IS NOT NULL
            THEN 'RAW_PRESENT_AND_MATCH_EXISTS'

        WHEN rh.provider_match_id IS NOT NULL AND bsl.match_id IS NULL
            THEN 'RAW_PRESENT_BUT_MATCH_MISSING'

        WHEN rh.provider_match_id IS NULL AND bsl.match_id IS NOT NULL
            THEN 'RAW_MISSING_BUT_MATCH_EXISTS'

        WHEN rh.provider_match_id IS NULL AND bda.match_id IS NOT NULL
            THEN 'RAW_MISSING_BUT_MATCH_EXISTS_OTHER_LEAGUE'

        WHEN rh.provider_match_id IS NULL AND bda.match_id IS NULL
            THEN 'RAW_MISSING_AND_MATCH_MISSING'

        ELSE 'UNCLASSIFIED'
    END AS backlog_classification

FROM src_map s
LEFT JOIN raw_hit rh
       ON rh.src_row_id = s.src_row_id
LEFT JOIN best_db_same_league bsl
       ON bsl.src_row_id = s.src_row_id
LEFT JOIN best_db_any bda
       ON bda.src_row_id = s.src_row_id
ORDER BY
    backlog_classification,
    s.league_name,
    s.event_name;