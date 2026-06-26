/*
===============================================================================
MATCHMATRIX – PLAYER MATCH STATISTICS COLUMNS AUDIT V1
===============================================================================
Zjistí skutečné sloupce cílové tabulky public.player_match_statistics,
abychom parser napsali přesně podle existující DB struktury.
===============================================================================
*/

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'player_match_statistics'
ORDER BY ordinal_position;