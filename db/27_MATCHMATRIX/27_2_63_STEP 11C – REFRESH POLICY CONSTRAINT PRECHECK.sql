-- CO: STEP 11C – REFRESH POLICY CONSTRAINT PRECHECK
-- K ČEMU: Ověřit vazby a povolené hodnoty sousedních registrů.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení systémového katalogu.

SELECT
    conrelid::regclass::text AS table_name,
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE conrelid IN (
    'ops.source_entity_time_coverage'::regclass,
    'ops.source_entity_time_scope_coverage'::regclass,
    'ops.harvest_scope_completion'::regclass,
    'ops.ingest_targets'::regclass
)
ORDER BY table_name, constraint_name;