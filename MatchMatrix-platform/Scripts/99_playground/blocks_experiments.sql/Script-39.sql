WITH outcome_probs AS (
  -- Normalizované pravděpodobnosti pro 1X2 per match (Manual)
  WITH base AS (
    SELECT
      od.match_id,
      o.code AS outcome,
      1.0 / od.odd_value AS inv
    FROM odds od
    JOIN market_outcomes o ON o.id = od.market_outcome_id
    JOIN markets m ON m.id = o.market_id
    JOIN bookmakers b ON b.id = od.bookmaker_id
    WHERE m.code = '1X2' AND b.name = 'Manual'
  ),
  norm AS (
    SELECT match_id, SUM(inv) AS inv_sum
    FROM base
    GROUP BY match_id
  )
  SELECT
    b.match_id,
    b.outcome,
    (b.inv / n.inv_sum) AS p
  FROM base b
  JOIN norm n ON n.match_id = b.match_id
),
ticket_p AS (
  SELECT
    gt.id AS ticket_id,
    EXP(SUM(LN(op.p))) AS ticket_prob
  FROM generated_tickets gt
  JOIN generated_runs gr ON gr.id = gt.run_id
  -- block-level volby z JSONu
  JOIN LATERAL jsonb_array_elements(gt.snapshot->'blocks') blk ON TRUE
  -- najdeme block record (kvůli id bloku)
  JOIN template_blocks tb
    ON tb.template_id = gr.template_id
   AND tb.block_index = (blk->>'block')::int
  -- rozpadneme blok na všechny zápasy v bloku
  JOIN template_block_matches tbm ON tbm.block_id = tb.id
  -- a najdeme p(match, outcome)
  JOIN outcome_probs op
    ON op.match_id = tbm.match_id
   AND op.outcome = (blk->>'outcome')
  WHERE gt.run_id = 4
  GROUP BY gt.id
)
UPDATE generated_tickets gt
SET probability = ROUND(tp.ticket_prob::numeric, 6)
FROM ticket_p tp
WHERE gt.id = tp.ticket_id;
