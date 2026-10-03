/*
CO:
STEP 9M – EXACT COVERAGE CHILD CONTRACT PRECHECK

K ČEMU:
Připravit bezpečný fyzický kontrakt budoucího detailního
coverage registru pod ops.source_entity_time_coverage.

CÍL:
Detailně evidovat přesné ověřené scope:
source × sport × layer × entity × time_mode
× competition/league × season/date range × evidence.

DŮLEŽITÉ:
Toto NENÍ Harvest Completion Registry.
Jde pouze o jemnou Source Coverage evidence.

KDE:
Databáze matchmatrix.

JAK:
Pouze SELECT.
Žádný DDL / INSERT / UPDATE / DELETE.
*/


/* =========================================================
   1. NAME COLLISION PRECHECK

   Prověříme několik pracovních názvů.
   ========================================================= */

SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'ops'
  AND table_name IN (
      'source_entity_time_scope_coverage',
      'source_entity_scope_coverage',
      'source_coverage_scope'
  )
ORDER BY table_name;


/* =========================================================
   2. PARENT COVERAGE – PŘESNÝ KONTRAKT
   ========================================================= */

SELECT
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.is_nullable,
    c.column_default
FROM information_schema.columns c
WHERE c.table_schema = 'ops'
  AND c.table_name = 'source_entity_time_coverage'
ORDER BY c.ordinal_position;


SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid, true) AS definition
FROM pg_constraint con
WHERE con.conrelid =
      'ops.source_entity_time_coverage'::regclass
ORDER BY con.conname;


/* =========================================================
   3. LEAGUE_PROVIDER_MAP – KONTRAKT
   ========================================================= */

SELECT
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.is_nullable,
    c.column_default
FROM information_schema.columns c
WHERE c.table_schema = 'public'
  AND c.table_name = 'league_provider_map'
ORDER BY c.ordinal_position;


SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid, true) AS definition
FROM pg_constraint con
WHERE con.conrelid =
      'public.league_provider_map'::regclass
ORDER BY con.conname;


/* =========================================================
   4. CANONICAL LEAGUE – KONTRAKT
   ========================================================= */

SELECT
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.is_nullable,
    c.column_default
FROM information_schema.columns c
WHERE c.table_schema = 'public'
  AND c.table_name = 'leagues'
ORDER BY c.ordinal_position;


SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid, true) AS definition
FROM pg_constraint con
WHERE con.conrelid =
      'public.leagues'::regclass
ORDER BY con.conname;


/* =========================================================
   5. AUDIT EVIDENCE – FK CANDIDATE
   ========================================================= */

SELECT
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.is_nullable,
    c.column_default
FROM information_schema.columns c
WHERE c.table_schema = 'ops'
  AND c.table_name = 'source_audit_evidence'
ORDER BY c.ordinal_position;


SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(con.oid, true) AS definition
FROM pg_constraint con
WHERE con.conrelid =
      'ops.source_audit_evidence'::regclass
ORDER BY con.conname;


/* =========================================================
   6. AKTUÁLNÍ PARENT COVERAGE ŘÁDKY
   ========================================================= */

SELECT
    coverage_id,
    source_id,
    sport_code,
    layer_type,
    entity,
    time_mode,
    coverage_status,
    history_from,
    history_to,
    evidence_status,
    tested_at
FROM ops.source_entity_time_coverage
WHERE source_id = 18
  AND sport_code = 'HB'
ORDER BY coverage_id;


/* =========================================================
   7. KONKRÉTNÍ LEAGUE MAP PRO NÁŠ TEST
   ========================================================= */

SELECT *
FROM public.league_provider_map
WHERE provider = 'api_handball'
  AND provider_league_id::text = '131';


/* =========================================================
   8. KONKRÉTNÍ EVIDENCE ID 58
   ========================================================= */

SELECT
    audit_evidence_id,
    source_id,
    audit_dimension,
    evidence_key,
    evidence_version,
    result_status,
    evidence_date,
    evidence_hash
FROM ops.source_audit_evidence
WHERE audit_evidence_id = 58;