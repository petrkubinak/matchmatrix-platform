-- 616_hk_fixtures_parse_to_stg_provider.sql
-- HK fixtures parser: staging.stg_api_payloads -> staging.stg_provider_fixtures

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
    raw_payload_id
)
SELECT
    p.provider,
    'HK' AS sport_code,

    (game ->> 'id')::text AS external_fixture_id,

    (game -> 'league' ->> 'id')::text AS external_league_id,
    (game -> 'league' ->> 'season')::text AS season,

    (game -> 'teams' -> 'home' ->> 'id')::text AS home_team_external_id,
    (game -> 'teams' -> 'away' ->> 'id')::text AS away_team_external_id,

    NULLIF(game ->> 'date', '')::timestamptz AS fixture_date,

    COALESCE(
        game -> 'status' ->> 'short',
        game -> 'status' ->> 'long',
        game ->> 'status'
    ) AS status_text,

    COALESCE(
        game -> 'scores' ->> 'home',
        game -> 'goals' ->> 'home'
    ) AS home_score,

    COALESCE(
        game -> 'scores' ->> 'away',
        game -> 'goals' ->> 'away'
    ) AS away_score,

    p.id AS raw_payload_id

FROM staging.stg_api_payloads p
CROSS JOIN LATERAL jsonb_array_elements(p.payload_json -> 'response') AS game
WHERE p.provider = 'api_hockey'
  AND p.sport_code = 'hockey'
  AND p.entity_type = 'fixtures'
ON CONFLICT DO NOTHING;