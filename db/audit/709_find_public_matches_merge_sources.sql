SELECT
    routine_schema,
    routine_name,
    routine_type
FROM information_schema.routines
WHERE LOWER(routine_definition) LIKE '%public.matches%'
ORDER BY routine_schema, routine_name;