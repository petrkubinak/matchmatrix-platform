-- CO: STEP 11B – REFRESH POLICY GRAIN PRECHECK
-- K ČEMU: Ověřit unikátní klíče coverage, completion a targetů.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení systémového katalogu indexů.

SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'ops'
  AND tablename IN (
      'source_entity_time_coverage',
      'source_entity_time_scope_coverage',
      'harvest_scope_completion',
      'ingest_targets'
  )
ORDER BY tablename, indexname;