-- 1. Sloupce a výchozí hodnoty
SELECT
    ordinal_position,
    column_name,
    data_type,
    udt_schema,
    udt_name,
    character_maximum_length,
    is_nullable,
    column_default,
    is_identity,
    identity_generation
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'data_acquisition_source_routing'
ORDER BY ordinal_position;


-- 2. Omezení: primární klíče, cizí klíče, UNIQUE a CHECK
SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid, true) AS constraint_definition
FROM pg_catalog.pg_constraint AS con
WHERE con.conrelid =
      'ops.data_acquisition_source_routing'::regclass
ORDER BY con.contype, con.conname;


-- 3. Indexy
SELECT
    indexname,
    indexdef
FROM pg_catalog.pg_indexes
WHERE schemaname = 'ops'
  AND tablename = 'data_acquisition_source_routing'
ORDER BY indexname;


-- 4. Aktuální počet řádků
SELECT COUNT(*) AS routing_row_count
FROM ops.data_acquisition_source_routing;