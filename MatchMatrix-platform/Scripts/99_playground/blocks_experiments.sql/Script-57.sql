SELECT array_agg(tb.block_index ORDER BY tb.block_index)
FROM template_blocks tb
WHERE tb.template_id = 1
  AND tb.block_type = 'VARIABLE'
  AND EXISTS (
    SELECT 1 FROM template_block_matches tbm
    WHERE tbm.block_id = tb.id
  );
