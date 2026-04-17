-- ============================================================================
-- 059a_check_player_season_statistics_columns.sql
-- Cíl:
--   Vypsat skutečné sloupce public.player_season_statistics
-- ============================================================================

SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'player_season_statistics'
ORDER BY ordinal_position;