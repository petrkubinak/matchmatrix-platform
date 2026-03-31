SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('template_fixed_picks','template_blocks','template_block_matches')
ORDER BY table_name, ordinal_position;