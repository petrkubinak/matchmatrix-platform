-- ============================================================================
-- MatchMatrix
-- Parse latest api_hockey fixtures(games) payload -> staging.stg_provider_fixtures
-- File: C:\MatchMatrix-platform\db\migrations\234_parse_api_hockey_fixtures.sql
-- ============================================================================

WITH src AS (
    SELECT
        p.id AS raw_payload_id,
        p.provider,
        p.sport_code,
        p.payload_json
    FROM staging.stg_api_payloads p
    WHERE p.id = (
        SELECT MAX(id)
        FROM staging.stg_api_payloads
        WHERE provider = 'api_hockey'
          AND sport_code = 'hockey'
          AND entity_type = 'fixtures'
          AND endpoint_name = 'games'
    )
),
items AS (
    SELECT
        s.raw_payload_id,
        s.provider,
        s.sport_code,
        j.value AS item_json
    FROM src s
    CROSS JOIN LATERAL jsonb_array_elements(
        CASE
            WHEN jsonb_typeof(s.payload_json -> 'response') = 'array'
                THEN s.payload_json -> 'response'
            ELSE '[]'::jsonb
        END
    ) j
),
norm AS (
    SELECT
        i.provider,
        i.sport_code,
        COALESCE(
            i.item_json -> 'game' ->> 'id',
            i.item_json ->> 'id'
        ) AS external_fixture_id,
        COALESCE(
            i.item_json -> 'league' ->> 'id',
            i.item_json ->> 'league'
        ) AS external_league_id,
        COALESCE(
            i.item_json -> 'league' ->> 'season',
            i.item_json ->> 'season'
        ) AS season,
        COALESCE(
            i.item_json -> 'teams' -> 'home' ->> 'id',
            i.item_json -> 'home' ->> 'id'
        ) AS home_team_external_id,
        COALESCE(
            i.item_json -> 'teams' -> 'away' ->> 'id',
            i.item_json -> 'away' ->> 'id'
        ) AS away_team_external_id,
        COALESCE(
            NULLIF(i.item_json -> 'game' ->> 'date', ''),
            NULLIF(i.item_json ->> 'date', '')
        )::timestamptz AS fixture_date,
        COALESCE(
            i.item_json -> 'status' ->> 'long',
            i.item_json -> 'status' ->> 'short',
            i.item_json ->> 'status'
        ) AS status_text,
        COALESCE(
    		i.item_json -> 'scores' ->> 'home',
		    i.item_json -> 'scores' -> 'home' ->> 'total',
		    i.item_json -> 'scores' -> 'home' ->> 'goals',
		    i.item_json -> 'scores' -> 'home' ->> 'score'
		) AS home_score,
		COALESCE(
		    i.item_json -> 'scores' ->> 'away',
		    i.item_json -> 'scores' -> 'away' ->> 'total',
		    i.item_json -> 'scores' -> 'away' ->> 'goals',
		    i.item_json -> 'scores' -> 'away' ->> 'score'
		) AS away_score,
        i.raw_payload_id
    FROM items i
)
INSERT INTO staging.stg_provider_fixtures
(
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
    n.provider,
    n.sport_code,
    n.external_fixture_id,
    n.external_league_id,
    n.season,
    n.home_team_external_id,
    n.away_team_external_id,
    n.fixture_date,
    n.status_text,
    n.home_score,
    n.away_score,
    n.raw_payload_id,
    now(),
    now()
FROM norm n
WHERE COALESCE(n.external_fixture_id, '') <> ''
ON CONFLICT DO NOTHING;