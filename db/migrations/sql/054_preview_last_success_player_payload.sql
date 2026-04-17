-- ============================================================================
-- 054_preview_last_success_player_payload.sql
-- Cíl:
--   Najít poslední úspěšný players payload, který má skutečná data
-- ============================================================================

SELECT
    id,
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    season,
    external_id,
    fetched_at,
    parse_status,
    parse_message,
    payload_json
FROM staging.stg_api_payloads
WHERE provider = 'api_football'
  AND sport_code = 'football'
  AND entity_type = 'players'
  AND endpoint_name = 'players'
  AND COALESCE((payload_json ->> 'results')::int, 0) > 0
  AND jsonb_typeof(payload_json -> 'response') = 'array'
  AND jsonb_array_length(payload_json -> 'response') > 0
ORDER BY fetched_at DESC
LIMIT 1;