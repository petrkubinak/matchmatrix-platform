-- =====================================================
-- MatchMatrix
-- Check real schema: players + player_provider_map
-- File: 008_check_player_tables.sql
-- =====================================================

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema IN ('public', 'staging')
  AND table_name IN ('players', 'player_provider_map', 'players_import', 'player_provider_map_import')
ORDER BY table_schema, table_name, ordinal_position;