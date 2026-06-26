SELECT
    column_name
FROM information_schema.columns
WHERE table_schema='public'
  AND table_name='players'
ORDER BY ordinal_position;

SELECT *
FROM public.players
LIMIT 1;