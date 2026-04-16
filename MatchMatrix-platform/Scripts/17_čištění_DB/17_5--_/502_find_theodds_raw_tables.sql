-- 502_find_theodds_raw_tables.sql
-- Cíl:
-- najít tabulky/sloupce, kde je uložený TheOdds raw obsah
-- a kde jsou ještě názvy týmů před mapováním na match_id

SELECT
    c.table_schema,
    c.table_name,
    c.column_name,
    c.data_type
FROM information_schema.columns c
WHERE
    c.table_schema IN ('public', 'staging', 'ops', 'work')
    AND (
        lower(c.table_name) LIKE '%odds%'
        OR lower(c.table_name) LIKE '%theodds%'
        OR lower(c.column_name) LIKE '%home%'
        OR lower(c.column_name) LIKE '%away%'
        OR lower(c.column_name) LIKE '%team%'
        OR lower(c.column_name) LIKE '%payload%'
        OR lower(c.column_name) LIKE '%json%'
        OR lower(c.column_name) LIKE '%raw%'
    )
ORDER BY c.table_schema, c.table_name, c.ordinal_position;