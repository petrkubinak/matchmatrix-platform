-- ============================================================================
-- 053_preview_player_payload.sql
-- Cíl:
--   Zobrazit 1 ukázkový payload pro api_football / football / players
--   a vidět skutečnou JSON strukturu v payload_json
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
ORDER BY fetched_at DESC
LIMIT 1;