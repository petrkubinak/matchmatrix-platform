SELECT
    id,
    provider,
    sport_code,
    entity,
    run_group,
    status,
    attempts,
    last_attempt,
    updated_at
FROM ops.ingest_planner
WHERE id IN (5845, 5846, 5847)
ORDER BY id;

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
WHERE parse_message LIKE 'planner v2%'
ORDER BY id DESC
LIMIT 10;