-- 911_check_bk_raw_payloads.sql

SELECT
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    season,
    parse_status,
    COUNT(*) AS payloads,
    MIN(fetched_at) AS first_fetched_at,
    MAX(fetched_at) AS last_fetched_at
FROM staging.stg_api_payloads
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
GROUP BY
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    season,
    parse_status
ORDER BY
    entity_type,
    season,
    endpoint_name,
    parse_status;