/* =============================================================================
CO:
    G4D-3 / STEP 4B-2
    ROUTING MASTER PHYSICAL CONTRACT DETAIL

K ČEMU:
    READ ONLY zjištění úplného fyzického kontraktu existující tabulky
    ops.data_acquisition_source_routing před vytvořením
    G4D-3 VALIDATE_ONLY PHYSICAL MIGRATION.

KDE:
    PostgreSQL matchmatrix / PC2

JAK:
    Spustit celý blok v DBeaveru.

BEZPEČNOST:
    - žádný APPLY
    - žádné CREATE / ALTER
    - žádný INSERT / UPDATE / DELETE
    - transakce READ ONLY
    - na konci ROLLBACK
============================================================================= */

BEGIN;

SET TRANSACTION READ ONLY;


/* ============================================================================
1. FYZICKÉ SLOUPCE ROUTING MASTERU
============================================================================ */

SELECT
    'ROUTING_COLUMN' AS section,
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.udt_schema,
    c.udt_name,
    c.character_maximum_length,
    c.numeric_precision,
    c.numeric_scale,
    c.is_nullable,
    c.column_default,
    c.is_identity,
    c.identity_generation
FROM information_schema.columns c
WHERE c.table_schema = 'ops'
  AND c.table_name = 'data_acquisition_source_routing'
ORDER BY c.ordinal_position;


/* ============================================================================
2. VŠECHNY CONSTRAINTY
============================================================================ */

SELECT
    'ROUTING_CONSTRAINT' AS section,
    con.conname AS constraint_name,
    con.contype AS constraint_type,
    con.condeferrable AS deferrable,
    con.condeferred AS initially_deferred,
    con.convalidated AS validated,
    pg_get_constraintdef(con.oid, true) AS constraint_definition
FROM pg_constraint con
JOIN pg_class rel
  ON rel.oid = con.conrelid
JOIN pg_namespace nsp
  ON nsp.oid = rel.relnamespace
WHERE nsp.nspname = 'ops'
  AND rel.relname = 'data_acquisition_source_routing'
ORDER BY
    con.contype,
    con.conname;


/* ============================================================================
3. INDEXY
============================================================================ */

SELECT
    'ROUTING_INDEX' AS section,
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'ops'
  AND tablename = 'data_acquisition_source_routing'
ORDER BY indexname;


/* ============================================================================
4. TRIGGERY
============================================================================ */

SELECT
    'ROUTING_TRIGGER' AS section,
    trg.tgname AS trigger_name,
    trg.tgenabled AS enabled,
    pg_get_triggerdef(trg.oid, true) AS trigger_definition
FROM pg_trigger trg
JOIN pg_class rel
  ON rel.oid = trg.tgrelid
JOIN pg_namespace nsp
  ON nsp.oid = rel.relnamespace
WHERE nsp.nspname = 'ops'
  AND rel.relname = 'data_acquisition_source_routing'
  AND NOT trg.tgisinternal
ORDER BY trg.tgname;


/* ============================================================================
5. OUTBOUND FOREIGN KEYS
============================================================================ */

SELECT
    'ROUTING_OUTBOUND_FK' AS section,
    con.conname AS constraint_name,
    pg_get_constraintdef(con.oid, true) AS constraint_definition
FROM pg_constraint con
JOIN pg_class rel
  ON rel.oid = con.conrelid
JOIN pg_namespace nsp
  ON nsp.oid = rel.relnamespace
WHERE nsp.nspname = 'ops'
  AND rel.relname = 'data_acquisition_source_routing'
  AND con.contype = 'f'
ORDER BY con.conname;


/* ============================================================================
6. INBOUND FOREIGN KEYS
============================================================================ */

SELECT
    'ROUTING_INBOUND_FK' AS section,
    src_ns.nspname AS source_schema,
    src_rel.relname AS source_table,
    con.conname AS constraint_name,
    pg_get_constraintdef(con.oid, true) AS constraint_definition
FROM pg_constraint con
JOIN pg_class src_rel
  ON src_rel.oid = con.conrelid
JOIN pg_namespace src_ns
  ON src_ns.oid = src_rel.relnamespace
JOIN pg_class dst_rel
  ON dst_rel.oid = con.confrelid
JOIN pg_namespace dst_ns
  ON dst_ns.oid = dst_rel.relnamespace
WHERE con.contype = 'f'
  AND dst_ns.nspname = 'ops'
  AND dst_rel.relname = 'data_acquisition_source_routing'
ORDER BY
    src_ns.nspname,
    src_rel.relname,
    con.conname;


/* ============================================================================
7. AKTUÁLNÍ POČET ŘÁDKŮ
============================================================================ */

SELECT
    'ROUTING_ROWS' AS section,
    COUNT(*) AS current_rows,
    CASE
        WHEN COUNT(*) = 0
            THEN 'PASS'
        ELSE
            'BLOCKER_REVIEW_REQUIRED'
    END AS status
FROM ops.data_acquisition_source_routing;


/* ============================================================================
8. KRITICKÉ LEGACY / TARGET SLOUPCE
============================================================================ */

SELECT
    'ROUTING_CRITICAL_COLUMN' AS section,
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.udt_name,
    c.is_nullable,
    c.column_default
FROM information_schema.columns c
WHERE c.table_schema = 'ops'
  AND c.table_name = 'data_acquisition_source_routing'
  AND c.column_name IN (
      'source_id',
      'source_ref_id',
      'source_name',
      'source_origin',
      'source_role',
      'decision_status',
      'is_active',
      'route_priority',
      'approved_at',
      'approved_by',
      'decision_note',
      'sport_code',
      'sport_key',
      'entity',
      'layer_type',
      'time_mode'
  )
ORDER BY c.ordinal_position;


/* ============================================================================
9. POTVRZENÍ, ŽE NOVÉ TARGET TABULKY STÁLE NEEXISTUJÍ
============================================================================ */

WITH target_objects(object_name) AS (
    VALUES
        ('source_master'),
        ('source_alias'),
        ('source_sport'),
        ('source_entity_time_coverage'),
        ('source_audit_evidence'),
        ('runtime_adapter'),
        ('source_adapter_binding')
)
SELECT
    'TARGET_OBJECT' AS section,
    t.object_name,
    CASE
        WHEN c.oid IS NULL
            THEN 'PASS_NOT_PRESENT'
        ELSE
            'BLOCKER_ALREADY_EXISTS'
    END AS status,
    c.relkind
FROM target_objects t
LEFT JOIN pg_namespace n
       ON n.nspname = 'ops'
LEFT JOIN pg_class c
       ON c.relnamespace = n.oid
      AND c.relname = t.object_name
ORDER BY t.object_name;


/* ============================================================================
10. FINÁLNÍ SAFETY CHECK
============================================================================ */

SELECT
    'SAFETY' AS section,
    'TRANSACTION_READ_ONLY' AS item,
    current_setting('transaction_read_only') AS value;


ROLLBACK;