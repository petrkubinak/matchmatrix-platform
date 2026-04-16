-- 496_i_export_last_6_team_not_mapped.sql
-- Cíl:
-- vytáhnout už jen poslední 100% zbývající TEAM_NOT_MAPPED případy

WITH src AS (
    SELECT
        u.provider,
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
league_map AS (
    SELECT
        s.*,
        l.id   AS league_id,
        l.name AS canonical_league_name
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
)
SELECT
    league_name AS theodds_key,
    canonical_league_name,
    event_name,
    home_raw,
    away_raw,
    home_normalized,
    away_normalized,
    home_team_id,
    away_team_id,
    CASE
        WHEN home_team_id IS NULL AND away_team_id IS NULL THEN 'BOTH_UNMAPPED'
        WHEN home_team_id IS NULL THEN 'HOME_UNMAPPED'
        WHEN away_team_id IS NULL THEN 'AWAY_UNMAPPED'
        ELSE 'OK'
    END AS unmapped_side
FROM team_map
WHERE home_team_id IS NULL
   OR away_team_id IS NULL
ORDER BY canonical_league_name, event_name;