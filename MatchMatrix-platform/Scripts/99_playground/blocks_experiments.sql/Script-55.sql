ALTER TABLE template_block_matches
ADD CONSTRAINT chk_tbm_match_order_1_3
CHECK (match_order BETWEEN 1 AND 3);
