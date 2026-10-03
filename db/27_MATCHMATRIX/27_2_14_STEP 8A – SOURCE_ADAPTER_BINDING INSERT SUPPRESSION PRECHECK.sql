/*
CO:
STEP 8A – SOURCE_ADAPTER_BINDING INSERT SUPPRESSION PRECHECK

K ČEMU:
Zjistit, zda INSERT do ops.source_adapter_binding
nepotlačuje trigger, rule nebo jiná vlastnost tabulky.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
*/


-- =========================================================
-- 1. VLASTNOSTI TABULKY
-- =========================================================

SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    c.relkind,
    c.relrowsecurity AS row_level_security,
    c.relforcerowsecurity AS force_row_level_security,
    c.relhasrules AS has_rules,
    c.relhastriggers AS has_triggers
FROM pg_class c
JOIN pg_namespace n
  ON n.oid = c.relnamespace
WHERE n.nspname = 'ops'
  AND c.relname = 'source_adapter_binding';


-- =========================================================
-- 2. VŠECHNY NEINTERNÍ TRIGGERY
-- =========================================================

SELECT
    t.tgname AS trigger_name,
    t.tgenabled AS trigger_enabled,
    pg_get_triggerdef(t.oid, true) AS trigger_definition
FROM pg_trigger t
WHERE t.tgrelid = 'ops.source_adapter_binding'::regclass
  AND NOT t.tgisinternal
ORDER BY t.tgname;


-- =========================================================
-- 3. RULES
-- =========================================================

SELECT
    schemaname,
    tablename,
    rulename,
    definition
FROM pg_rules
WHERE schemaname = 'ops'
  AND tablename = 'source_adapter_binding'
ORDER BY rulename;


-- =========================================================
-- 4. RLS POLICIES
-- =========================================================

SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE schemaname = 'ops'
  AND tablename = 'source_adapter_binding'
ORDER BY policyname;