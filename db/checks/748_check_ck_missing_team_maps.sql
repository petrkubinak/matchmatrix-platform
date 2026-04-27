-- 748_check_ck_missing_team_maps.sql

WITH ck_src AS (
    SELECT
        f.external_fixture_id,
        f.external_league_id,
        f.home_team_external_id,
        f.away_team_external_id,
        f.fixture_date
    FROM staging.stg_provider_fixtures f
    WHERE f.provider = 'api_cricket'
      AND f.sport_code = 'CK'
),
missing_home AS (
    SELECT DISTINCT
        'HOME' AS side,
        s.home_team_external_id AS missing_team_external_id
    FROM ck_src s
    LEFT JOIN public.team_provider_map tpm
        ON tpm.provider = 'api_cricket'
       AND tpm.provider_team_id = s.home_team_external_id
    WHERE tpm.team_id IS NULL
),
missing_away AS (
    SELECT DISTINCT
        'AWAY' AS side,
        s.away_team_external_id AS missing_team_external_id
    FROM ck_src s
    LEFT JOIN public.team_provider_map tpm
        ON tpm.provider = 'api_cricket'
       AND tpm.provider_team_id = s.away_team_external_id
    WHERE tpm.team_id IS NULL
)
SELECT *
FROM (
    SELECT * FROM missing_home
    UNION
    SELECT * FROM missing_away
) q
ORDER BY missing_team_external_id, side;