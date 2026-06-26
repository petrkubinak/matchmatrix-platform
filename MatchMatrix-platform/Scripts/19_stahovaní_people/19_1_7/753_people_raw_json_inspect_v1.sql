/*
753_people_raw_json_inspect_v1.sql

Účel:
- ukáže první položku response z každého RAW payloadu
- podle toho napíšeme parser do stg_provider_players / stg_provider_coaches
*/

SELECT
    id,
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    jsonb_pretty(payload_json->'response'->0) AS first_response_item
FROM staging.stg_api_payloads
WHERE id IN (743, 744, 745, 746)
ORDER BY id;