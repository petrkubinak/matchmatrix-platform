INSERT INTO template_block_matches (block_id, match_id, match_order)
SELECT tb.id AS block_id, tb.match_id, 1
FROM template_blocks tb
WHERE tb.match_id IS NOT NULL
ON CONFLICT (block_id, match_id) DO NOTHING;
