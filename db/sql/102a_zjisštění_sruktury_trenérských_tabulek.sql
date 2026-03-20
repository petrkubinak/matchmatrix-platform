SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE (table_schema = 'public' AND table_name IN ('coaches', 'team_coaches'))
   OR (table_schema = 'staging' AND table_name IN ('stg_provider_coaches'))
ORDER BY table_schema, table_name, ordinal_position;