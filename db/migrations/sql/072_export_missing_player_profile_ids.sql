-- ============================================================================
-- 072_export_missing_player_profile_ids.sql
-- Cíl:
--   Vypsat čistý seznam player IDs pro další ingest player profiles
-- ============================================================================

SELECT
    player_external_id
FROM work.missing_player_profile_ids
WHERE provider = 'api_football'
  AND sport_code = 'football'
ORDER BY player_external_id;