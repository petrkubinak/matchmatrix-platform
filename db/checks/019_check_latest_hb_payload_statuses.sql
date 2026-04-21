
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
    created_at
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
  AND sport_code = 'handball'
  AND entity_type = 'fixtures'
  AND external_id IN
  (
    '150_2024',
    '151_2024',
    '152_2024',
    '153_2024',
    '154_2024',
    '155_2024',
    '156_2024',
    '157_2024',
    '158_2024',
    '159_2024'
  )
ORDER BY id DESC;