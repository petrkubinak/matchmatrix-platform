-- 504_inspect_matches_columns.sql
-- Cíl: zjistit strukturu matches tabulky

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'matches'
ORDER BY ordinal_position;