/*
CO:
STEP 7 – SOURCE_ADAPTER_BINDING SEMANTICS PRECHECK

K ČEMU:
Ověřit skutečný význam worker_binding_id, account_id a binding_status
před prvním VALIDATE_ONLY bindingem API-Sports -> api_handball.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT. Žádný INSERT, UPDATE ani DDL.
*/


-- =========================================================
-- 1. KOMENTÁŘ TABULKY
-- =========================================================

SELECT
    obj_description(
        'ops.source_adapter_binding'::regclass,
        'pg_class'
    ) AS table_comment;


-- =========================================================
-- 2. KOMENTÁŘE JEDNOTLIVÝCH SLOUPCŮ
-- =========================================================

SELECT
    a.attnum AS ordinal_position,
    a.attname AS column_name,
    col_description(
        'ops.source_adapter_binding'::regclass,
        a.attnum
    ) AS column_comment
FROM pg_attribute a
WHERE a.attrelid = 'ops.source_adapter_binding'::regclass
  AND a.attnum > 0
  AND NOT a.attisdropped
ORDER BY a.attnum;


-- =========================================================
-- 3. ODKAZY VE VIEW DEFINICÍCH
-- =========================================================

SELECT
    schemaname,
    viewname
FROM pg_views
WHERE definition ILIKE '%source_adapter_binding%'
ORDER BY schemaname, viewname;


-- =========================================================
-- 4. ODKAZY VE MATERIALIZED VIEW
-- =========================================================

SELECT
    schemaname,
    matviewname
FROM pg_matviews
WHERE definition ILIKE '%source_adapter_binding%'
ORDER BY schemaname, matviewname;


-- =========================================================
-- 5. FUNKCE / PROCEDURY, KTERÉ TABULKU ZMIŇUJÍ
-- =========================================================

SELECT
    n.nspname AS schema_name,
    p.proname AS routine_name,
    CASE p.prokind
        WHEN 'f' THEN 'FUNCTION'
        WHEN 'p' THEN 'PROCEDURE'
        ELSE p.prokind::text
    END AS routine_type
FROM pg_proc p
JOIN pg_namespace n
  ON n.oid = p.pronamespace
WHERE CASE
          WHEN p.prokind IN ('f', 'p')
          THEN pg_get_functiondef(p.oid)
                   ILIKE '%source_adapter_binding%'
          ELSE false
      END
ORDER BY
    n.nspname,
    p.proname;


-- =========================================================
-- 6. OVĚŘENÍ PK GENEROVÁNÍ
-- =========================================================

SELECT
    pg_get_serial_sequence(
        'ops.source_adapter_binding',
        'source_adapter_binding_id'
    ) AS pk_sequence;


-- =========================================================
-- 7. VŠECHNY DOSAVADNÍ HODNOTY BINDING_STATUS
-- =========================================================

SELECT
    binding_status,
    COUNT(*) AS rows_count
FROM ops.source_adapter_binding
GROUP BY binding_status
ORDER BY binding_status;


-- =========================================================
-- 8. CELKOVÝ STAV TABULKY
-- =========================================================

SELECT
    COUNT(*) AS binding_rows,
    MAX(source_adapter_binding_id) AS max_binding_id
FROM ops.source_adapter_binding;


-- =========================================================
-- 9. POTVRZENÍ ÚČTU API_HANDBALL
-- =========================================================

SELECT
    id AS account_id,
    provider,
    account_name,
    plan_code,
    is_active,
    api_base_url
FROM ops.provider_accounts
WHERE id = 5
   OR provider = 'api_handball'
ORDER BY id;


-- =========================================================
-- 10. POTVRZENÍ ČTYŘ HB WORKERŮ
-- =========================================================

SELECT
    id AS worker_registry_id,
    provider,
    sport_code,
    entity,
    worker_type,
    worker_script,
    is_supported,
    is_active
FROM ops.provider_worker_registry
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
ORDER BY id;