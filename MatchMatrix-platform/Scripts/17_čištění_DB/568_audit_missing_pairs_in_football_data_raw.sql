-- ============================================================
-- 568_audit_missing_pairs_in_football_data_raw.sql
-- MatchMatrix / Football-Data
--
-- Účel:
-- pro unmatched_theodds NO_MATCH_ID ověřit, zda stejný pár existuje
-- v raw football-data payloadu posledního football_data runu
--
-- Předpoklad:
-- - importovaná tabulka public.unmatched_theodds
-- - poslední football_data run je run_id=192 (uprav v params pokud je jiný)
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
        u.issue_code
    FROM public.unmatched_theodds u
    WHERE u.issue_code = 'NO_MATCH_ID'
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
        COALESCE(m -> 'homeTeam' ->> 'name', m -> 'home' ->> 'name') AS home_raw,
        COALESCE(m -> 'awayTeam' ->> 'name', m -> 'away' ->> 'name') AS away_raw
    FROM raw_base rb
    CROSS JOIN LATERAL jsonb_array_elements(rb.matches_json) m
),

raw_norm AS (
    SELECT
        rm.*,
        lower(btrim(rm.home_raw)) AS home_name_key,
        lower(btrim(rm.away_raw)) AS away_name_key
    FROM raw_matches rm
),

src_norm AS (
    SELECT
        s.*,
        lower(btrim(s.home_raw)) AS home_name_key,
        lower(btrim(s.away_raw)) AS away_name_key
    FROM src s
),

joined AS (
    SELECT
        s.src_row_id,
        s.league_name,
        s.event_name,
        s.home_raw AS src_home_raw,
        s.away_raw AS src_away_raw,
        r.competition_name,
        r.endpoint,
        r.provider_match_id,
        r.kickoff_raw,
        r.home_raw AS raw_home_raw,
        r.away_raw AS raw_away_raw
    FROM src_norm s
    LEFT JOIN raw_norm r
      ON s.home_name_key = r.home_name_key
     AND s.away_name_key = r.away_name_key
)

SELECT
    src_row_id,
    league_name,
    event_name,
    src_home_raw,
    src_away_raw,
    competition_name,
    endpoint,
    provider_match_id,
    kickoff_raw,
    raw_home_raw,
    raw_away_raw,
    CASE
        WHEN provider_match_id IS NOT NULL THEN 'RAW_HAS_MATCH'
        ELSE 'RAW_DOES_NOT_HAVE_MATCH'
    END AS audit_result
FROM joined
ORDER BY league_name, event_name, provider_match_id NULLS LAST;