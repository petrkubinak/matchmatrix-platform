-- 036_check_last_bk_fixtures_payload.sql

SELECT
    id,
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    parse_status,
    parse_message,
    COALESCE((payload_json ->> 'results')::int, 0) AS results_count,
    jsonb_typeof(payload_json -> 'response') AS response_type,
    jsonb_array_length(COALESCE(payload_json -> 'response', '[]'::jsonb)) AS response_len,
    fetched_at
FROM staging.stg_api_payloads
WHERE provider = 'api_sport'
  AND sport_code = 'basketball'
  AND entity_type = 'fixtures'
ORDER BY id DESC
LIMIT 5;