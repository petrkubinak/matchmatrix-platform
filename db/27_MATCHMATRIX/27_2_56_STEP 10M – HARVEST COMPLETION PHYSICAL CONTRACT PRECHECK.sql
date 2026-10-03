/*
CO:
STEP 10M – HARVEST COMPLETION PHYSICAL CONTRACT PRECHECK

K ČEMU:
Připravit fyzický kontrakt nového exact Harvest Completion Registry.

CÍL:
Ověřit:
- možné názvové kolize,
- PK/FK typy,
- stabilitu ingest target identity,
- exact coverage identity,
- audit evidence identity,
- harvest run provenance,
- source identity.

DŮLEŽITÉ:
Zatím NIC nevytváříme.

Harvest Completion musí umět reprezentovat i:

TARGET = YES
DATA = 0
COMPLETION = NOT_STARTED

proto exact coverage link nesmí být automaticky povinný.

JAK:
Pouze SELECT.
*/


/* =========================================================
   1. NAME COLLISION PRECHECK
   ========================================================= */

SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'ops'
  AND table_name IN (
      'harvest_scope_completion',
      'harvest_completion_registry',
      'source_harvest_completion',
      'data_acquisition_harvest_completion'
  )
ORDER BY
    table_name;


/* =========================================================
   2. INGEST_TARGETS – PŘESNÝ FYZICKÝ KONTRAKT
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
ORDER BY
    ordinal_position;


SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(
        con.oid,
        true
    ) AS definition
FROM pg_constraint con
WHERE con.conrelid =
      'ops.ingest_targets'::regclass
ORDER BY
    con.conname;


/* =========================================================
   3. EXACT SOURCE COVERAGE – KONTRAKT
   ========================================================= */

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'source_entity_time_scope_coverage'
ORDER BY
    ordinal_position;


SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(
        con.oid,
        true
    ) AS definition
FROM pg_constraint con
WHERE con.conrelid =
      'ops.source_entity_time_scope_coverage'::regclass
ORDER BY
    con.conname;


/* =========================================================
   4. SOURCE MASTER – KONTRAKT
   ========================================================= */

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'source_master'
ORDER BY
    ordinal_position;


SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(
        con.oid,
        true
    ) AS definition
FROM pg_constraint con
WHERE con.conrelid =
      'ops.source_master'::regclass
ORDER BY
    con.conname;


/* =========================================================
   5. SOURCE_AUDIT_EVIDENCE – KONTRAKT
   ========================================================= */

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'source_audit_evidence'
ORDER BY
    ordinal_position;


SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(
        con.oid,
        true
    ) AS definition
FROM pg_constraint con
WHERE con.conrelid =
      'ops.source_audit_evidence'::regclass
ORDER BY
    con.conname;


/* =========================================================
   6. HARVEST_RUN_MONITOR – KONTRAKT
   ========================================================= */

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'harvest_run_monitor'
ORDER BY
    ordinal_position;


SELECT
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    pg_get_constraintdef(
        con.oid,
        true
    ) AS definition
FROM pg_constraint con
WHERE con.conrelid =
      'ops.harvest_run_monitor'::regclass
ORDER BY
    con.conname;


/* =========================================================
   7. SPORT FK CONTRACT
   ========================================================= */

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'sports'
ORDER BY
    ordinal_position;


/* =========================================================
   8. LEAGUE FK CONTRACT
   ========================================================= */

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'leagues'
ORDER BY
    ordinal_position;


/* =========================================================
   9. NAŠICH 211 HB TARGETŮ – IDENTITA A DUPLICITY
   ========================================================= */

SELECT
    COUNT(*) AS target_rows,

    COUNT(DISTINCT id)
        AS distinct_target_ids,

    COUNT(DISTINCT
        canonical_league_id::text
        || '|'
        || provider_league_id::text
        || '|'
        || season::text
    )
        AS distinct_target_scopes

FROM ops.ingest_targets

WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND season = '2024'
  AND enabled = true;


/* =========================================================
   10. DUPLICITY TARGET GRAINU
   ========================================================= */

SELECT
    canonical_league_id,
    provider_league_id,
    season,
    COUNT(*) AS rows_count

FROM ops.ingest_targets

WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND season = '2024'
  AND enabled = true

GROUP BY
    canonical_league_id,
    provider_league_id,
    season

HAVING COUNT(*) > 1

ORDER BY
    rows_count DESC,
    canonical_league_id;


/* =========================================================
   11. EXISTUJÍCÍ EXACT COVERAGE LINK PRO HB TARGETY
   ========================================================= */

SELECT
    COUNT(*) AS enabled_targets,

    COUNT(*) FILTER (
        WHERE d.scope_coverage_id IS NOT NULL
    ) AS targets_with_exact_coverage,

    COUNT(*) FILTER (
        WHERE d.scope_coverage_id IS NULL
    ) AS targets_without_exact_coverage

FROM ops.ingest_targets t

LEFT JOIN ops.source_entity_time_scope_coverage d
  ON d.canonical_league_id = t.canonical_league_id
 AND d.source_competition_key
        = t.provider_league_id::text
 AND d.source_season_key
        = t.season::text

WHERE t.provider = 'api_handball'
  AND t.sport_code = 'HB'
  AND t.season = '2024'
  AND t.enabled = true;


/* =========================================================
   12. FK DELETE / UPDATE CHOVÁNÍ
       PRO INGEST_TARGETS A DALŠÍ KANDIDÁTY
   ========================================================= */

SELECT
    n.nspname AS referencing_schema,
    c.relname AS referencing_table,
    con.conname AS constraint_name,

    pg_get_constraintdef(
        con.oid,
        true
    ) AS definition

FROM pg_constraint con

JOIN pg_class c
  ON c.oid = con.conrelid

JOIN pg_namespace n
  ON n.oid = c.relnamespace

WHERE con.contype = 'f'

  AND con.confrelid IN (
      'ops.ingest_targets'::regclass,
      'ops.source_entity_time_scope_coverage'::regclass,
      'ops.source_audit_evidence'::regclass,
      'ops.harvest_run_monitor'::regclass
  )

ORDER BY
    con.confrelid::regclass::text,
    n.nspname,
    c.relname,
    con.conname;