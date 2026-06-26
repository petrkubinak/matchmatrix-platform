UPDATE staging.stg_api_payloads
SET
    parse_status = 'superseded',
    parse_message = 'Superseded by successful planner v2 run RAW 753-755.'
WHERE id IN (750, 751, 752);

SELECT
    id,
    provider,
    sport_code,
    entity_type,
    parse_status,
    parse_message
FROM staging.stg_api_payloads
WHERE id IN (750, 751, 752, 753, 754, 755)
ORDER BY id;