-- ============================================================================
-- 074_export_missing_player_profile_batch.sql
-- Cíl:
--   Vypsat konkrétní batch player IDs pro další ingest player profiles.
--
-- Použití:
--   Změň číslo batch_no v WHERE, např.:
--   = 1
--   = 2
--   ...
--   = 11
-- ============================================================================

SELECT
    player_external_id
FROM work.missing_player_profile_batches
WHERE provider = 'api_football'
  AND sport_code = 'football'
  AND batch_no = 1
ORDER BY rn;