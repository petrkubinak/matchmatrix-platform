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
    jsonb_array_length(payload_json->'response') AS response_count,
    fetched_at
FROM staging.stg_api_payloads
WHERE id IN (743, 744, 745, 746)
ORDER BY id;