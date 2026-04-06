-- 545_a_inspect_unmatched_theodds_columns.sql
-- Cíl: zjistit skutečnou strukturu tabulky public.unmatched_theodds

SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'unmatched_theodds'
ORDER BY ordinal_position;

-- rychlá ukázka dat
SELECT *
FROM public.unmatched_theodds
LIMIT 5;