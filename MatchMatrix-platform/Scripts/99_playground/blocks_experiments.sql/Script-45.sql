CREATE OR REPLACE FUNCTION generate_run(p_template_id INT, p_bookmaker TEXT DEFAULT 'Manual')
RETURNS INT AS $$
DECLARE
  v_run_id INT;
  v_var_blocks INT[];
BEGIN
  -- vytvoř run
  INSERT INTO generated_runs (template_id) VALUES (p_template_id) RETURNING id INTO v_run_id;

  -- najdi variabilní bloky (max 3, seřazené)
  SELECT array_agg(block_index ORDER BY block_index)
  INTO v_var_blocks
  FROM template_blocks
  WHERE template_id = p_template_id AND block_type = 'VARIABLE';

  -- bezpečnost: max 3 variabilní bloky
  IF array_length(v_var_blocks, 1) IS NULL THEN
    RAISE EXCEPTION 'Template % has no VARIABLE blocks', p_template_id;
  END IF;

  IF array_length(v_var_blocks, 1) > 3 THEN
    RAISE EXCEPTION 'Template % has more than 3 VARIABLE blocks', p_template_id;
  END IF;

  -- vygeneruj kombinace 3^n
  IF array_length(v_var_blocks, 1) = 1 THEN
    INSERT INTO generated_tickets (run_id, ticket_index, probability, snapshot)
    SELECT
      v_run_id,
      ROW_NUMBER() OVER (ORDER BY a.outcome) AS ticket_index,
      NULL::numeric,
      jsonb_build_object('blocks',
        (SELECT jsonb_agg(x ORDER BY (x->>'block')::int)
         FROM (
           SELECT jsonb_build_object('block', tb.block_index, 'outcome',
                   CASE WHEN tb.block_type='FIXED' THEN mo.code ELSE a.outcome END
                 ) AS x
           FROM template_blocks tb
           LEFT JOIN market_outcomes mo ON mo.id = tb.market_outcome_id
           WHERE tb.template_id = p_template_id
         ) s
        )
      )
    FROM (VALUES ('1'),('X'),('2')) a(outcome);

  ELSIF array_length(v_var_blocks, 1) = 2 THEN
    INSERT INTO generated_tickets (run_id, ticket_index, probability, snapshot)
    SELECT
      v_run_id,
      ROW_NUMBER() OVER (ORDER BY a.outcome, b.outcome) AS ticket_index,
      NULL::numeric,
      jsonb_build_object('blocks',
        (SELECT jsonb_agg(x ORDER BY (x->>'block')::int)
         FROM (
           SELECT jsonb_build_object('block', tb.block_index, 'outcome',
                   CASE
                     WHEN tb.block_type='FIXED' THEN mo.code
                     WHEN tb.block_index = v_var_blocks[1] THEN a.outcome
                     WHEN tb.block_index = v_var_blocks[2] THEN b.outcome
                     ELSE NULL
                   END
                 ) AS x
           FROM template_blocks tb
           LEFT JOIN market_outcomes mo ON mo.id = tb.market_outcome_id
           WHERE tb.template_id = p_template_id
         ) s
        )
      )
    FROM (VALUES ('1'),('X'),('2')) a(outcome)
    CROSS JOIN (VALUES ('1'),('X'),('2')) b(outcome);

  ELSE
    -- 3 variabilní bloky => 27 tiketů
    INSERT INTO generated_tickets (run_id, ticket_index, probability, snapshot)
    SELECT
      v_run_id,
      ROW_NUMBER() OVER (ORDER BY a.outcome, b.outcome, c.outcome) AS ticket_index,
      NULL::numeric,
      jsonb_build_object('blocks',
        (SELECT jsonb_agg(x ORDER BY (x->>'block')::int)
         FROM (
           SELECT jsonb_build_object('block', tb.block_index, 'outcome',
                   CASE
                     WHEN tb.block_type='FIXED' THEN mo.code
                     WHEN tb.block_index = v_var_blocks[1] THEN a.outcome
                     WHEN tb.block_index = v_var_blocks[2] THEN b.outcome
                     WHEN tb.block_index = v_var_blocks[3] THEN c.outcome
                     ELSE NULL
                   END
                 ) AS x
           FROM template_blocks tb
           LEFT JOIN market_outcomes mo ON mo.id = tb.market_outcome_id
           WHERE tb.template_id = p_template_id
         ) s
        )
      )
    FROM (VALUES ('1'),('X'),('2')) a(outcome)
    CROSS JOIN (VALUES ('1'),('X'),('2')) b(outcome)
    CROSS JOIN (VALUES ('1'),('X'),('2')) c(outcome);
  END IF;

  -- spočti ticket_probability (multi-match bloky přes template_block_matches)
  WITH outcome_probs AS (
    WITH base AS (
      SELECT
        od.match_id,
        o.code AS outcome,
        1.0 / od.odd_value AS inv
      FROM odds od
      JOIN market_outcomes o ON o.id = od.market_outcome_id
      JOIN markets m ON m.id = o.market_id
      JOIN bookmakers bk ON bk.id = od.bookmaker_id
      WHERE m.code = '1X2' AND bk.name = p_bookmaker
    ),
    norm AS (
      SELECT match_id, SUM(inv) AS inv_sum
      FROM base
      GROUP BY match_id
    )
    SELECT b.match_id, b.outcome, (b.inv / n.inv_sum) AS p
    FROM base b JOIN norm n ON n.match_id = b.match_id
  ),
  ticket_p AS (
    SELECT
      gt.id AS ticket_id,
      EXP(SUM(LN(op.p))) AS ticket_prob
    FROM generated_tickets gt
    JOIN LATERAL jsonb_array_elements(gt.snapshot->'blocks') blk ON TRUE
    JOIN template_blocks tb
      ON tb.template_id = p_template_id
     AND tb.block_index = (blk->>'block')::int
    JOIN template_block_matches tbm ON tbm.block_id = tb.id
    JOIN outcome_probs op
      ON op.match_id = tbm.match_id
     AND op.outcome = (blk->>'outcome')
    WHERE gt.run_id = v_run_id
    GROUP BY gt.id
  )
  UPDATE generated_tickets gt
  SET probability = ROUND(tp.ticket_prob::numeric, 6)
  FROM ticket_p tp
  WHERE gt.id = tp.ticket_id;

  -- spočti run_probability jako sumu tiketů
  UPDATE generated_runs r
  SET run_probability = s.p
  FROM (
    SELECT run_id, ROUND(SUM(probability)::numeric, 6) AS p
    FROM generated_tickets
    WHERE run_id = v_run_id
    GROUP BY run_id
  ) s
  WHERE r.id = s.run_id;

  RETURN v_run_id;
END;
$$ LANGUAGE plpgsql;
