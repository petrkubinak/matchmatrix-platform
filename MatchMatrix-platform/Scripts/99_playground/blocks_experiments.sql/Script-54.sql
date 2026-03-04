ALTER TABLE template_blocks
ADD CONSTRAINT chk_template_blocks_block_index_positive
CHECK (block_index > 0);
