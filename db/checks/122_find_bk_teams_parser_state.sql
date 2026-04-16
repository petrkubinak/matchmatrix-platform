-- 122_find_bk_teams_parser_state.sql

-- 1) parse status breakdown
SELECT
    parse_status,
    COUNT(*) AS cnt
FROM staging.stg_api_payloads
WHERE provider = 'api_sport'
  AND sport_code IN ('bk', 'basketball')
  AND (
        entity_type ILIKE '%team%'
     OR endpoint_name ILIKE '%team%'
  )
GROUP BY parse_status
ORDER BY parse_status;

-- 2) payloady s chybou
SELECT
    id,
    parse_status,
    parse_message,
    created_at
FROM staging.stg_api_payloads
WHERE provider = 'api_sport'
  AND sport_code IN ('bk', 'basketball')
  AND (
        entity_type ILIKE '%team%'
     OR endpoint_name ILIKE '%team%'
  )
  AND parse_status = 'error'
ORDER BY created_at DESC
LIMIT 20;

-- 3) payloady pending
SELECT
    id,
    parse_status,
    created_at
FROM staging.stg_api_payloads
WHERE provider = 'api_sport'
  AND sport_code IN ('bk', 'basketball')
  AND (
        entity_type ILIKE '%team%'
     OR endpoint_name ILIKE '%team%'
  )
  AND (parse_status IS NULL OR parse_status = 'pending')
ORDER BY created_at DESC
LIMIT 20;