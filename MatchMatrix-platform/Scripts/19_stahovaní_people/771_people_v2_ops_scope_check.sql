/*
771_people_v2_ops_scope_check.sql

Účel:
- ověřit reálné sloupce OPS tabulek pro PEOPLE PIPELINE V2
- podle toho připravíme targets/planner napojení bez chyb ve schématu
*/

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name IN (
      'ingest_targets',
      'ingest_planner',
      'provider_jobs',
      'provider_people_audit',
      'runtime_entity_audit'
  )
ORDER BY table_name, ordinal_position;