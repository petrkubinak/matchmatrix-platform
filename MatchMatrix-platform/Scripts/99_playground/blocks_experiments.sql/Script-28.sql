INSERT INTO template_block_matches (block_id, match_id, match_order)
SELECT id AS block_id, match_id, 1
FROM template_blocks
WHERE match_id IS NOT NULL
ON CONFLICT (block_id, match_id) DO NOTHING;
