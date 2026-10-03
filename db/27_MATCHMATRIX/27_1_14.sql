BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;

-- 1. Bezpečnost aktuální kontrolní transakce
SELECT
    '01_TRANSACTION_SAFETY' AS check_name,
    current_database() AS database_name,
    current_user AS database_user,
    current_setting('server_version') AS server_version,
    current_setting('transaction_read_only') AS transaction_read_only,
    current_setting('transaction_isolation') AS transaction_isolation,
    CASE
        WHEN current_database() = 'matchmatrix'
         AND current_setting('transaction_read_only') = 'on'
         AND current_setting('transaction_isolation') = 'repeatable read'
        THEN 'PASS'
        ELSE 'BLOCKER'
    END AS result;


-- 2. Existence osmi cílových objektů
-- Sedm nových objektů se zatím očekává jako neexistujících.
WITH targets (object_name, should_exist) AS (
    VALUES
        ('ops.source_master', false),
        ('ops.source_alias', false),
        ('ops.source_sport', false),
        ('ops.source_entity_time_coverage', false),
        ('ops.source_audit_evidence', false),
        ('ops.runtime_adapter', false),
        ('ops.source_adapter_binding', false),
        ('ops.data_acquisition_source_routing', true)
)
SELECT
    object_name,
    should_exist,
    to_regclass(object_name) IS NOT NULL AS exists_now,
    CASE
        WHEN (to_regclass(object_name) IS NOT NULL) = should_exist
        THEN 'PASS'
        ELSE 'REVIEW'
    END AS result
FROM targets
ORDER BY object_name;


-- 3. Routing musí nadále zůstat prázdný
SELECT
    '03_ROUTING_EMPTY' AS check_name,
    COUNT(*) AS routing_row_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'BLOCKER'
    END AS result
FROM ops.data_acquisition_source_routing;


-- 4. Aktuální sloupce routingu
SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default,
    is_identity,
    identity_generation
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'data_acquisition_source_routing'
ORDER BY ordinal_position;


-- 5. Omezení routingu, včetně stavu jejich validace
SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    con.convalidated AS is_validated,
    pg_get_constraintdef(con.oid, true) AS constraint_definition
FROM pg_catalog.pg_constraint AS con
WHERE con.conrelid =
      'ops.data_acquisition_source_routing'::regclass
ORDER BY con.contype, con.conname;


-- 6. Indexy routingu, včetně provozního stavu
SELECT
    idx.relname AS index_name,
    i.indisunique AS is_unique,
    i.indisvalid AS is_valid,
    i.indisready AS is_ready,
    pg_get_indexdef(i.indexrelid) AS index_definition
FROM pg_catalog.pg_index AS i
JOIN pg_catalog.pg_class AS idx
  ON idx.oid = i.indexrelid
WHERE i.indrelid =
      'ops.data_acquisition_source_routing'::regclass
ORDER BY idx.relname;


-- 7. Uživatelské triggery routingu
-- Prázdný výsledek znamená, že zde žádné nejsou.
SELECT
    t.tgname AS trigger_name,
    t.tgenabled AS enabled_mode,
    pg_get_triggerdef(t.oid, true) AS trigger_definition
FROM pg_catalog.pg_trigger AS t
WHERE t.tgrelid =
      'ops.data_acquisition_source_routing'::regclass
  AND NOT t.tgisinternal
ORDER BY t.tgname;


-- 8. Úplnost a jedinečnost mapování sportů
SELECT
    '08_SPORT_MAPPING' AS check_name,
    COUNT(*) AS sport_count,
    COUNT(*) FILTER (
        WHERE code IS NULL OR btrim(code) = ''
    ) AS missing_codes,
    COUNT(*) FILTER (
        WHERE sport_key IS NULL OR btrim(sport_key) = ''
    ) AS missing_keys,
    CASE
        WHEN COUNT(*) > 0
         AND COUNT(*) FILTER (
             WHERE code IS NULL OR btrim(code) = ''
                OR sport_key IS NULL OR btrim(sport_key) = ''
         ) = 0
         AND COUNT(*) = COUNT(DISTINCT code)
         AND COUNT(*) = COUNT(DISTINCT sport_key)
        THEN 'PASS'
        ELSE 'BLOCKER'
    END AS result
FROM public.sports;


-- 9. Bezpečnost znovu na konci kontrolní transakce
SELECT
    '09_FINAL_TRANSACTION_SAFETY' AS check_name,
    current_setting('transaction_read_only') AS transaction_read_only,
    CASE
        WHEN current_setting('transaction_read_only') = 'on'
        THEN 'PASS'
        ELSE 'BLOCKER'
    END AS result;

ROLLBACK;