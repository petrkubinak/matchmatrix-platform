-- 501_inspect_odds_table.sql
-- Cíl: zjistit strukturu odds tabulky

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'odds'
ORDER BY ordinal_position;