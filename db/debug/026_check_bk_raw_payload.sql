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
    payload_json
FROM staging.stg_api_payloads
WHERE provider = 'api_sport'
  AND sport_code = 'basketball'
  AND entity_type = 'teams'
ORDER BY id DESC
LIMIT 1;