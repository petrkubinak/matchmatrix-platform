/*
===============================================================================
MATCHMATRIX – PEOPLE SEASON STATS COLUMNS AUDIT V1
===============================================================================

Zjistí skutečné sloupce tabulky:
staging.stg_provider_player_season_stats
===============================================================================
*/

SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'stg_provider_player_season_stats'
ORDER BY ordinal_position;