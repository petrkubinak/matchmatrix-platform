ALTER TABLE template_blocks
ADD CONSTRAINT chk_template_blocks_outcome_by_type
CHECK (
  (block_type = 'FIXED' AND market_outcome_id IS NOT NULL)
  OR
  (block_type = 'VARIABLE' AND market_outcome_id IS NULL)
);
