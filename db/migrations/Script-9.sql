-- ============================================================================
-- MatchMatrix
-- Parse latest api_volleyball leagues payload -> staging.stg_provider_leagues
-- File: C:\MatchMatrix-platform\db\migrations\235_parse_api_volleyball_leagues.sql
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
        WHERE provider = 'api_volleyball'
          AND sport_code = 'volleyball'
          AND entity_type = 'leagues'
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
        COALESCE(i.item_json -> 'league' ->> 'id', i.item_json ->> 'id') AS external_league_id,
        COALESCE(i.item_json -> 'league' ->> 'name', i.item_json ->> 'name') AS league_name,
        COALESCE(i.item_json -> 'country' ->> 'name', i.item_json ->> 'country') AS country_name,
        COALESCE(i.item_json -> 'seasons' -> 0 ->> 'season', i.item_json ->> 'season') AS season,
        i.raw_payload_id,
        TRUE AS is_active
    FROM items i
)
INSERT INTO staging.stg_provider_leagues
(
    provider,
    sport_code,
    external_league_id,
    league_name,
    country_name,
    season,
    raw_payload_id,
    is_active,
    created_at,
    updated_at
)
SELECT
    n.provider,
    n.sport_code,
    n.external_league_id,
    n.league_name,
    n.country_name,
    n.season,
    n.raw_payload_id,
    n.is_active,
    now(),
    now()
FROM norm n
WHERE COALESCE(n.external_league_id, '') <> ''
ON CONFLICT DO NOTHING;