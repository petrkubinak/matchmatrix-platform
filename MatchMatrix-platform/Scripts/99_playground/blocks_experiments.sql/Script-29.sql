CREATE TABLE IF NOT EXISTS template_block_matches (
  id SERIAL PRIMARY KEY,
  block_id INT NOT NULL REFERENCES template_blocks(id) ON DELETE CASCADE,
  match_id INT NOT NULL REFERENCES matches(id),
  match_order INT NOT NULL DEFAULT 1,
  UNIQUE (block_id, match_id),
  UNIQUE (block_id, match_order)
);
