/*
CO:
STEP 9H – SOURCE_AUDIT_EVIDENCE CONTRACT PRECHECK

K ČEMU:
Zjistit přesný fyzický a sémantický kontrakt evidence registru,
aby runtime test STEP 9G byl uložen jako dohledatelný důkaz
před vytvořením SOURCE_ENTITY_TIME_COVERAGE.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
Žádný INSERT / UPDATE / DELETE / DDL.
*/


-- =========================================================
-- 1. SLOUPCE
-- =========================================================

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'source_audit_evidence'
ORDER BY ordinal_position;


-- =========================================================
-- 2. CONSTRAINTS
-- =========================================================

SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid, true) AS definition
FROM pg_constraint con
WHERE con.conrelid = 'ops.source_audit_evidence'::regclass
ORDER BY con.conname;


-- =========================================================
-- 3. INDEXY
-- =========================================================

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'ops'
  AND tablename = 'source_audit_evidence'
ORDER BY indexname;


-- =========================================================
-- 4. EXISTUJÍCÍ HODNOTY / SLOVNÍK PRAXE
--    Nechceme vymýšlet nové typy nebo statusy,
--    pokud už projekt nějaké používá.
-- =========================================================

SELECT *
FROM ops.source_audit_evidence
ORDER BY 1
LIMIT 30;


-- =========================================================
-- 5. EXISTUJÍCÍ EVIDENCE PRO API-SPORTS
-- =========================================================

SELECT *
FROM ops.source_audit_evidence
WHERE source_id = 18
ORDER BY 1;


-- =========================================================
-- 6. SOUHRN TEXTOVÝCH HODNOT
--    Výstup jako JSON nám ukáže skutečně používané hodnoty
--    bez hádání názvů jednotlivých statusů.
-- =========================================================

SELECT
    COUNT(*) AS total_evidence_rows,
    jsonb_agg(DISTINCT to_jsonb(e))
        FILTER (WHERE e.source_id = 18) AS api_sports_existing_evidence
FROM ops.source_audit_evidence e;