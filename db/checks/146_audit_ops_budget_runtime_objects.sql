SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name IN (
      'ingest_runtime_config',
      'provider_jobs',
      'provider_accounts',
      'api_request_log'
  )
ORDER BY table_name, ordinal_position;

SELECT
    table_schema,
    table_name
FROM information_schema.views
WHERE table_schema IN ('ops', 'public')
  AND table_name ILIKE '%budget%';

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema IN ('ops', 'public')
  AND table_name ILIKE '%budget%';