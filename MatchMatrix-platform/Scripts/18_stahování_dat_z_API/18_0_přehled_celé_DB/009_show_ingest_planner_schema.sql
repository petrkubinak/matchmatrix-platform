-- 009_show_ingest_planner_schema.sql

SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name = 'ingest_planner'
ORDER BY ordinal_position;