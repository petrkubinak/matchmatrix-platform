ALTER TABLE template_blocks
  ADD COLUMN match_id INT REFERENCES matches(id),
  ADD COLUMN market_outcome_id INT REFERENCES market_outcomes(id);

-- Volitelné, ale silně doporučené: blok musí mít přiřazený zápas
ALTER TABLE template_blocks
  ALTER COLUMN match_id SET NOT NULL;

-- Pravidlo:
-- FIXED blok musí mít market_outcome_id
-- VARIABLE blok ho mít nesmí (protože bude generovat 1/X/2)
ALTER TABLE template_blocks
  ADD CONSTRAINT chk_block_fixed_vs_variable
  CHECK (
    (block_type = 'FIXED' AND market_outcome_id IS NOT NULL)
 OR (block_type = 'VARIABLE' AND market_outcome_id IS NULL)
  );
INSERT INTO templates (name, max_variable_blocks)
VALUES ('Vzor 1 - demo (1 match, 1 variabilní blok)', 4)
RETURNING id;
INSERT INTO template_blocks (template_id, block_index, block_type, match_id, market_outcome_id)
VALUES (
  (SELECT id FROM templates WHERE name = 'Vzor 1 - demo (1 match, 1 variabilní blok)'),
  1,
  'VARIABLE',
  1,
  NULL
)
RETURNING *;
