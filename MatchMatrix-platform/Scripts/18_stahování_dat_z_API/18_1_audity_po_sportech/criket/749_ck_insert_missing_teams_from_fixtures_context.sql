-- 749_ck_insert_missing_teams_from_fixtures_context.sql

WITH fixture_team_ids AS (
    SELECT DISTINCT
        home_team_external_id AS external_team_id
    FROM staging.stg_provider_fixtures
    WHERE provider = 'api_cricket'
      AND sport_code = 'CK'

    UNION

    SELECT DISTINCT
        away_team_external_id AS external_team_id
    FROM staging.stg_provider_fixtures
    WHERE provider = 'api_cricket'
      AND sport_code = 'CK'
)
INSERT INTO staging.stg_provider_teams (
    provider,
    sport_code,
    external_team_id,
    team_name,
    country_name,
    external_league_id,
    season,
    raw_payload_id,
    is_active,
    created_at,
    updated_at
)
SELECT
    'api_cricket' AS provider,
    'CK' AS sport_code,
    ft.external_team_id,
    'CK Team ' || ft.external_team_id AS team_name,
    NULL AS country_name,
    NULL AS external_league_id,
    NULL AS season,
    NULL AS raw_payload_id,
    true AS is_active,
    now(),
    now()
FROM fixture_team_ids ft
LEFT JOIN staging.stg_provider_teams t
    ON t.provider = 'api_cricket'
   AND t.sport_code = 'CK'
   AND t.external_team_id = ft.external_team_id
WHERE t.id IS NULL;