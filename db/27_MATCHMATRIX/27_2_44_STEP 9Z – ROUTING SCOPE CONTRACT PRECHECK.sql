/*
CO:
STEP 9Z – ROUTING SCOPE CONTRACT PRECHECK

K ČEMU:
Ověřit, zda současný canonical routing dokáže reprezentovat
přesný potvrzený scope:

API-Sports
HB
CORE
fixtures
HISTORY_FAN / HISTORY_PREDICTION
league 24881
source league 131
source season 2024

CÍL:
Nevytvořit širší route, než dovoluje CONFIRMED exact coverage.

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. FYZICKÝ KONTRAKT ROUTING TABULKY
   ========================================================= */

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'data_acquisition_source_routing'
ORDER BY ordinal_position;


/* =========================================================
   2. CONSTRAINTS
   ========================================================= */

SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid, true) AS definition
FROM pg_constraint con
WHERE con.conrelid =
      'ops.data_acquisition_source_routing'::regclass
ORDER BY con.conname;


/* =========================================================
   3. INDEXY
   ========================================================= */

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'ops'
  AND tablename = 'data_acquisition_source_routing'
ORDER BY indexname;


/* =========================================================
   4. EXISTUJÍCÍ ROUTING DATA
   ========================================================= */

SELECT *
FROM ops.data_acquisition_source_routing
ORDER BY 1
LIMIT 100;


/* =========================================================
   5. OBJEKTY, KTERÉ BY MOHLY UŽ EXISTOVAT PRO DETAIL ROUTINGU
   ========================================================= */

SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'ops'
  AND (
       table_name ILIKE '%routing%'
       OR table_name ILIKE '%route%'
  )
ORDER BY table_name;


/* =========================================================
   6. ROUTING-LIKE OBJEKTY S LEAGUE / SEASON / SCOPE
   ========================================================= */

WITH objects AS (
    SELECT
        table_schema,
        table_name,
        array_agg(column_name ORDER BY ordinal_position) AS columns
    FROM information_schema.columns
    WHERE table_schema = 'ops'
    GROUP BY
        table_schema,
        table_name
)
SELECT
    table_schema,
    table_name,
    columns
FROM objects
WHERE
    (
        table_name ILIKE '%routing%'
        OR table_name ILIKE '%route%'
    )
AND (
       columns::text ILIKE '%league%'
    OR columns::text ILIKE '%season%'
    OR columns::text ILIKE '%scope%'
    OR columns::text ILIKE '%coverage%'
)
ORDER BY table_name;


/* =========================================================
   7. NAŠE CONFIRMED EXACT COVERAGE
   ========================================================= */

SELECT
    d.scope_coverage_id,
    d.coverage_id,
    c.source_id,
    c.sport_code,
    c.layer_type,
    c.entity,
    c.time_mode,
    c.coverage_status AS parent_status,

    d.scope_type,
    d.canonical_league_id,
    d.canonical_season_id,
    d.source_competition_key,
    d.source_season_key,
    d.scope_status,

    d.audit_evidence_id

FROM ops.source_entity_time_scope_coverage d

JOIN ops.source_entity_time_coverage c
  ON c.coverage_id = d.coverage_id

WHERE c.source_id = 18
ORDER BY d.scope_coverage_id;