/*
MATCHMATRIX BK FIXTURES PARSER FIX V1

Co to je:
- Opravený parser pro API-Sport Basketball fixtures/games RAW payload.

K čemu to je:
- Převede RAW JSON z staging.stg_api_payloads do staging.stg_provider_fixtures.

Kde se výsledek projeví:
- staging.stg_provider_fixtures

Jak se využije na webu:
- BK zápasy dostanou správné skóre a statusy.
- Následný merge aktualizuje public.matches.
*/

WITH latest_payload AS (
    SELECT
        id AS raw_payload_id,
        payload_json
    FROM staging.stg_api_payloads
    WHERE provider = 'api_sport'
      AND sport_code = 'basketball'
      AND entity_type = 'fixtures'
      AND endpoint_name = 'games'
    ORDER BY id DESC
    LIMIT 1
),
games AS (
    SELECT
        lp.raw_payload_id,
        jsonb_array_elements(lp.payload_json -> 'response') AS game
    FROM latest_payload lp
)
INSERT INTO staging.stg_provider_fixtures (
    provider,
    sport_code,
    external_fixture_id,
    external_league_id,
    season,
    home_team_external_id,
    away_team_external_id,
    fixture_date,
    status_text,
    home_score,
    away_score,
    raw_payload_id,
    created_at,
    updated_at
)
SELECT
    'api_sport' AS provider,
    'BK' AS sport_code,
    game ->> 'id' AS external_fixture_id,
    game #>> '{league,id}' AS external_league_id,
    game #>> '{league,season}' AS season,
    game #>> '{teams,home,id}' AS home_team_external_id,
    game #>> '{teams,away,id}' AS away_team_external_id,
    (game ->> 'date')::timestamptz AS fixture_date,
    game #>> '{status,short}' AS status_text,
    game #>> '{scores,home,total}' AS home_score,
    game #>> '{scores,away,total}' AS away_score,
    raw_payload_id,
    NOW(),
    NOW()
FROM games
WHERE game ->> 'id' IS NOT NULL
ON CONFLICT DO NOTHING;

SELECT
    'BK parsed rows in staging.stg_provider_fixtures from payload 1319' AS check_name,
    COUNT(*) AS rows_count
FROM staging.stg_provider_fixtures
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND raw_payload_id = 1319;