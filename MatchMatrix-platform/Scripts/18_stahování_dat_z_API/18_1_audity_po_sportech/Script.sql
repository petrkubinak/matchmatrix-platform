SELECT
    id,
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    fetched_at,
    parse_status,
    created_at
FROM staging.stg_api_payloads
WHERE provider = 'api_cricket'
  AND sport_code = 'CK'
  AND entity_type = 'fixtures'
ORDER BY id DESC
LIMIT 20;