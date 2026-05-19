-- 910_find_bk_staging_sources.sql

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'staging'
  AND (
        table_name ILIKE '%basket%'
     OR table_name ILIKE '%bk%'
     OR table_name ILIKE '%sport%'
  )
ORDER BY
    table_schema,
    table_name;