SELECT tb.id, tb.block_index, tb.block_type,
       COUNT(tbm.id) AS matches_in_block
FROM template_blocks tb
LEFT JOIN template_block_matches tbm ON tbm.block_id = tb.id
WHERE tb.template_id = 1
GROUP BY tb.id, tb.block_index, tb.block_type
HAVING COUNT(tbm.id) = 0;
