WITH outcome_probs AS (
  WITH base AS (
    SELECT
      od.match_id,
      o.code AS outcome,
      od.odd_value,
      1.0 / od.odd_value AS inv
    FROM odds od
    JOIN market_outcomes o ON o.id = od.market_outcome_id
    JOIN markets m ON m.id = o.market_id
    JOIN bookmakers b ON b.id = od.bookmaker_id
    WHERE m.code = '1X2'
      AND b.name = 'Manual'
  ),
  norm AS (
    SELECT match_id, SUM(inv) AS inv_sum
    FROM base
    GROUP BY match_id
  )
  SELECT
    b.match_id,
    b.outcome,
    b.odd_value,
    (b.inv / n.inv_sum) AS p
  FROM base b
  JOIN norm n ON n.match_id = b.match_id
)
SELECT
  gt.ticket_index,
  gt.probability AS ticket_probability,
  jsonb_agg(
    jsonb_build_object(
      'block', (blk->>'block')::int,
      'match', ht.name || ' vs ' || at.name,
      'outcome', (blk->>'outcome'),
      'odd', op.odd_value,
      'p', ROUND(op.p::numeric, 6)
    )
    ORDER BY (blk->>'block')::int
  ) AS legs
FROM generated_tickets gt
JOIN LATERAL jsonb_array_elements(gt.snapshot->'blocks') blk ON TRUE
JOIN template_blocks tb
  ON tb.template_id = (SELECT template_id FROM generated_runs WHERE id = gt.run_id)
 AND tb.block_index = (blk->>'block')::int
JOIN matches m ON m.id = tb.match_id
JOIN teams ht ON ht.id = m.home_team_id
JOIN teams at ON at.id = m.away_team_id
JOIN outcome_probs op
  ON op.match_id = tb.match_id
 AND op.outcome = (blk->>'outcome')
WHERE gt.run_id = 3
GROUP BY gt.ticket_index, gt.probability
ORDER BY gt.ticket_index;
