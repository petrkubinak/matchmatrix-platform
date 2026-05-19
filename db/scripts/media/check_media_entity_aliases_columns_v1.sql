-- check_media_entity_aliases_columns_v1.sql

SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'media_entity_aliases'
ORDER BY ordinal_position;


SELECT *
FROM public.media_entity_aliases
LIMIT 20;