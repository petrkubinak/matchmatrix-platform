-- 496_c_export_team_not_mapped_alias_candidates.sql
-- Cíl:
-- vytáhnout unikátní seznam názvů, které ještě nejsou namapované přes team_aliases
-- a seřadit je podle četnosti výskytu v unmatched_theodds

WITH src AS (
    SELECT
        u.league_name,
        u.home_raw,
        u.away_raw,
        u.home_normalized,
        u.away_normalized,
        u.issue_code
    FROM public.unmatched_theodds u
    WHERE u.issue_code = 'NO_MATCH_ID'
),

league_map AS (
    SELECT
        s.*,
        l.id AS league_id,
        l.name AS canonical_league_name
    FROM src s
    LEFT JOIN public.leagues l
        ON LOWER(l.theodds_key) = LOWER(s.league_name)
),

home_check AS (
    SELECT
        lm.league_name,
        lm.canonical_league_name,
        'HOME' AS side,
        lm.home_raw AS raw_name,
        lm.home_normalized AS normalized_name,
        ta.team_id
    FROM league_map lm
    LEFT JOIN public.team_aliases ta
        ON LOWER(ta.alias) = LOWER(lm.home_normalized)
),

away_check AS (
    SELECT
        lm.league_name,
        lm.canonical_league_name,
        'AWAY' AS side,
        lm.away_raw AS raw_name,
        lm.away_normalized AS normalized_name,
        ta.team_id
    FROM league_map lm
    LEFT JOIN public.team_aliases ta
        ON LOWER(ta.alias) = LOWER(lm.away_normalized)
),

all_missing AS (
    SELECT * FROM home_check WHERE team_id IS NULL
    UNION ALL
    SELECT * FROM away_check WHERE team_id IS NULL
)

SELECT
    league_name AS theodds_key,
    canonical_league_name,
    normalized_name,
    MIN(raw_name) AS sample_raw_name,
    COUNT(*) AS occurrences
FROM all_missing
GROUP BY
    league_name,
    canonical_league_name,
    normalized_name
ORDER BY
    occurrences DESC,
    canonical_league_name,
    normalized_name;