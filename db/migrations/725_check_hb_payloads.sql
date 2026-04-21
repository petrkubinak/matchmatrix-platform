-- 725_check_hb_payloads.sql

-- 1) kolik máme HB payloadů podle entity_type
SELECT
    provider,
    sport_code,
    entity_type,
    COUNT(*) AS payload_count
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
GROUP BY provider, sport_code, entity_type
ORDER BY payload_count DESC;

-- 2) stav parse_status
SELECT
    entity_type,
    parse_status,
    COUNT(*) AS cnt
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
GROUP BY entity_type, parse_status
ORDER BY entity_type, parse_status;

-- 3) poslední fixtures payloady
SELECT
    id,
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    parse_status,
    created_at
FROM staging.stg_api_payloads
WHERE provider = 'api_handball'
  AND entity_type = 'fixtures'
ORDER BY created_at DESC
LIMIT 20;