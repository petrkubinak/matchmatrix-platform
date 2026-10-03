/*
CO:
STEP 10I – HB HISTORICAL TARGET UNIVERSE CONTRACT PRECHECK

K ČEMU:
Zjistit, zda ops.ingest_targets obsahuje použitelnou
autoritativní nebo provozní cílovou množinu pro HB harvest.

CÍL:
Zjistit:
- fyzický kontrakt tabulky,
- používané statusy / enable flagy,
- provider / sport / league / season informace,
- skutečné HB target rows,
- zda target množina odpovídá našim historickým 130 scope.

DŮLEŽITÉ:
ops.ingest_targets zatím NEPROHLAŠUJEME za canonical coverage truth.
Pouze zjišťujeme jeho skutečnou roli.

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. FYZICKÝ KONTRAKT
   ========================================================= */

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'ingest_targets'
ORDER BY ordinal_position;


/* =========================================================
   2. CONSTRAINTS
   ========================================================= */

SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid, true) AS definition
FROM pg_constraint con
WHERE con.conrelid = 'ops.ingest_targets'::regclass
ORDER BY con.conname;


/* =========================================================
   3. INDEXY
   ========================================================= */

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'ops'
  AND tablename = 'ingest_targets'
ORDER BY indexname;


/* =========================================================
   4. KOMENTÁŘ TABULKY A SLOUPCŮ
   ========================================================= */

SELECT
    obj_description(
        'ops.ingest_targets'::regclass,
        'pg_class'
    ) AS table_comment;


SELECT
    a.attnum AS ordinal_position,
    a.attname AS column_name,
    col_description(
        'ops.ingest_targets'::regclass,
        a.attnum
    ) AS column_comment
FROM pg_attribute a
WHERE a.attrelid = 'ops.ingest_targets'::regclass
  AND a.attnum > 0
  AND NOT a.attisdropped
ORDER BY a.attnum;


/* =========================================================
   5. CELKOVÝ POČET
   ========================================================= */

SELECT
    COUNT(*) AS total_ingest_targets
FROM ops.ingest_targets;


/* =========================================================
   6. HB / API_HANDALL KANDIDÁTNÍ TARGETY

   Záměrně JSONB, abychom nic nehádali o názvech sloupců.
   ========================================================= */

SELECT
    to_jsonb(x) AS hb_target
FROM ops.ingest_targets x
WHERE to_jsonb(x)::text ILIKE '%api_handball%'
   OR to_jsonb(x)::text ILIKE '%handball%'
ORDER BY 1
LIMIT 300;


/* =========================================================
   7. POČET HB KANDIDÁTNÍCH TARGETŮ
   ========================================================= */

SELECT
    COUNT(*) AS hb_candidate_targets
FROM ops.ingest_targets x
WHERE to_jsonb(x)::text ILIKE '%api_handball%'
   OR to_jsonb(x)::text ILIKE '%handball%';


/* =========================================================
   8. JAKÉ KLÍČE / POLE TABULKA REÁLNĚ NABÍZÍ
   ========================================================= */

SELECT DISTINCT
    jsonb_object_keys(to_jsonb(x)) AS json_key
FROM ops.ingest_targets x
ORDER BY 1;