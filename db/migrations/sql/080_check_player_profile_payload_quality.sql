-- ============================================================================
-- 080_check_player_profile_payload_quality.sql
-- Cíl:
--   Zjistit kvalitu player profile payloadů uložených ve stg_api_payloads
-- ============================================================================

SELECT 'payloads_total' AS metric, COUNT(*)::text AS value
FROM staging.stg_api_payloads
WHERE provider = 'api_football'
  AND sport_code = 'football'
  AND entity_type = 'player_profiles'
  AND endpoint_name = 'players'

UNION ALL

SELECT 'payloads_results_gt_0', COUNT(*)::text
FROM staging.stg_api_payloads
WHERE provider = 'api_football'
  AND sport_code = 'football'
  AND entity_type = 'player_profiles'
  AND endpoint_name = 'players'
  AND COALESCE((payload_json ->> 'results')::int, 0) > 0

UNION ALL

SELECT 'payloads_results_0', COUNT(*)::text
FROM staging.stg_api_payloads
WHERE provider = 'api_football'
  AND sport_code = 'football'
  AND entity_type = 'player_profiles'
  AND endpoint_name = 'players'
  AND COALESCE((payload_json ->> 'results')::int, 0) = 0

UNION ALL

SELECT 'payloads_with_rate_limit_error', COUNT(*)::text
FROM staging.stg_api_payloads
WHERE provider = 'api_football'
  AND sport_code = 'football'
  AND entity_type = 'player_profiles'
  AND endpoint_name = 'players'
  AND LOWER(COALESCE(payload_json -> 'errors' ->> 'rateLimit', '')) <> ''

UNION ALL

SELECT 'payloads_with_nonempty_response_array', COUNT(*)::text
FROM staging.stg_api_payloads
WHERE provider = 'api_football'
  AND sport_code = 'football'
  AND entity_type = 'player_profiles'
  AND endpoint_name = 'players'
  AND jsonb_typeof(payload_json -> 'response') = 'array'
  AND jsonb_array_length(payload_json -> 'response') > 0;