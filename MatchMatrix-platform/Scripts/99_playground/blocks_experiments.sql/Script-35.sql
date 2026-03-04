-- dosadíš si správné block_id pro block_index=1, tady používám (SELECT...) aby to bylo bez ručního přepisu

INSERT INTO template_block_matches (block_id, match_id, match_order)
VALUES
(
  (SELECT id FROM template_blocks WHERE template_id=1 AND block_index=1),
  2,
  2
),
(
  (SELECT id FROM template_blocks WHERE template_id=1 AND block_index=1),
  3,
  3
)
ON CONFLICT (block_id, match_id) DO NOTHING;
