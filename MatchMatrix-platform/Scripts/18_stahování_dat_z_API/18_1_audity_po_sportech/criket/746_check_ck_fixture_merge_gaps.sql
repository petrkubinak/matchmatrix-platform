-- 746_check_ck_fixture_merge_gaps.sql

WITH ck_src AS (
    SELECT
        f.external_fixture_id,
        f.external_league_id,
        f.home_team_external_id,
        f.away_team_external_id,
        f.fixture_date,
        f.status_text,
        f.home_score,
        f.away_score,
        f.season
    FROM staging.stg_provider_fixtures f
    WHERE f.provider = 'api_cricket'
      AND f.sport_code = 'CK'
),
ck_diag AS (
    SELECT
        s.external_fixture_id,
        s.external_league_id,
        s.home_team_external_id,
        s.away_team_external_id,
        s.fixture_date,
        s.status_text,
        s.home_score,
        s.away_score,
        s.season,

        l.id  AS league_id,
        th.team_id AS home_team_id,
        ta.team_id AS away_team_id,
        m.id  AS existing_match_id,

        CASE
            WHEN l.id IS NULL THEN 'MISSING_LEAGUE'
            WHEN th.team_id IS NULL THEN 'MISSING_HOME_TEAM_MAP'
            WHEN ta.team_id IS NULL THEN 'MISSING_AWAY_TEAM_MAP'
            WHEN m.id IS NOT NULL THEN 'ALREADY_IN_PUBLIC'
            ELSE 'READY_TO_MERGE'
        END AS merge_status
    FROM ck_src s
    LEFT JOIN public.leagues l
        ON l.ext_source = 'api_cricket'
       AND l.ext_league_id = s.external_league_id
       AND l.sport_id = 14
    LEFT JOIN public.team_provider_map th
        ON th.provider = 'api_cricket'
       AND th.provider_team_id = s.home_team_external_id
    LEFT JOIN public.team_provider_map ta
        ON ta.provider = 'api_cricket'
       AND ta.provider_team_id = s.away_team_external_id
    LEFT JOIN public.matches m
        ON m.ext_source = 'api_cricket'
       AND m.ext_match_id = s.external_fixture_id
)
SELECT
    merge_status,
    COUNT(*) AS rows_count
FROM ck_diag
GROUP BY merge_status
ORDER BY merge_status;