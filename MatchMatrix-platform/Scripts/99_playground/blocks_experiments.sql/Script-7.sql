SELECT o.id, m.code AS market, o.code AS outcome, o.label
FROM market_outcomes o
JOIN markets m ON m.id = o.market_id
WHERE m.code = '1X2' AND o.code = '1';
INSERT INTO template_blocks (template_id, block_index, block_type, match_id, market_outcome_id)
VALUES (
  1,              -- template_id (z tvého screenshotu je to 1)
  2,              -- druhý blok
  'FIXED',        -- konstanta
  1,              -- match_id (Arsenal–Chelsea je 1)
  (SELECT o.id
   FROM market_outcomes o
   JOIN markets m ON m.id = o.market_id
   WHERE m.code = '1X2' AND o.code = '1')
)
RETURNING *;
