SELECT *
FROM template_blocks
WHERE (block_type='FIXED' AND market_outcome_id IS NULL)
   OR (block_type='VARIABLE' AND market_outcome_id IS NOT NULL);
