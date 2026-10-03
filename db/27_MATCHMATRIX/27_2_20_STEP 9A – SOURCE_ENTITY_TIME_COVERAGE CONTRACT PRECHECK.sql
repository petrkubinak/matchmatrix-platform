/*
CO:
STEP 9A – SOURCE_ENTITY_TIME_COVERAGE CONTRACT PRECHECK

K ČEMU:
Zjistit přesný fyzický kontrakt tabulky,
do které budeme zapisovat potvrzené source × sport × layer × entity × time_mode coverage.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
Bez INSERT / UPDATE / DELETE / DDL.
*/


-- =========================================================
-- 1. SLOUPCE TABULKY
-- =========================================================

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'source_entity_time_coverage'
ORDER BY ordinal_position;


-- =========================================================
-- 2. CONSTRAINTS
-- =========================================================

SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid, true) AS definition
FROM pg_constraint con
WHERE con.conrelid = 'ops.source_entity_time_coverage'::regclass
ORDER BY con.conname;


-- =========================================================
-- 3. INDEXY
-- =========================================================

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'ops'
  AND tablename = 'source_entity_time_coverage'
ORDER BY indexname;


-- =========================================================
-- 4. AKTUÁLNÍ POČET ŘÁDKŮ
-- =========================================================

SELECT
    COUNT(*) AS coverage_rows
FROM ops.source_entity_time_coverage;


-- =========================================================
-- 5. PŘÍPADNÉ ŘÁDKY PRO API-SPORTS / HB
-- =========================================================

SELECT *
FROM ops.source_entity_time_coverage
WHERE source_id = 18
  AND sport_code = 'HB'
ORDER BY 1;


-- =========================================================
-- 6. OVĚŘENÍ PERSISTENTNÍCH BINDINGŮ Z STEP 8F
-- =========================================================

SELECT
    source_adapter_binding_id,
    source_id,
    adapter_id,
    sport_code,
    entity,
    binding_status,
    is_active
FROM ops.source_adapter_binding
WHERE source_id = 18
  AND adapter_id = 9
  AND sport_code = 'HB'
ORDER BY source_adapter_binding_id;