-- =====================================================================
-- 283_show_public_teams_columns.sql
-- Zjisti skutecne sloupce public.teams pro pripravu insert batch
-- =====================================================================

SELECT
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name   = 'teams'
ORDER BY ordinal_position;