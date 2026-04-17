-- ============================================================================
-- 075_check_player_profiles_loaded.sql
-- Cíl:
--   Ověřit, kolik řádků je ve staging.stg_provider_player_profiles
-- ============================================================================

SELECT COUNT(*) AS cnt
FROM staging.stg_provider_player_profiles;