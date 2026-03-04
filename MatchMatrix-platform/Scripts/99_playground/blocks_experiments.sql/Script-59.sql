CREATE OR REPLACE FUNCTION create_block_from_selection(
  p_template_id INT,
  p_selection_id INT,
  p_block_type TEXT,              -- 'FIXED' / 'VARIABLE'
  p_fixed_outcome_code TEXT DEFAULT NULL  -- např. '1' pro FIXED
)
RETURNS INT AS $$
DECLARE
  v_block_index INT;
  v_block_id INT;
  v_outcome_id INT;
BEGIN
  -- zjisti další block_index
  SELECT COALESCE(MAX(block_index), 0) + 1
  INTO v_block_index
  FROM template_blocks
  WHERE template_id = p_template_id;

  -- FIXED outcome -> market_outcome_id
  IF p_block_type = 'FIXED' THEN
    SELECT mo.id INTO v_outcome_id
    FROM market_outcomes mo
    JOIN markets m ON m.id = mo.market_id
    WHERE m.code = '1X2' AND mo.code = p_fixed_outcome_code;

    IF v_outcome_id IS NULL THEN
      RAISE EXCEPTION 'Unknown fixed outcome code: %', p_fixed_outcome_code;
    END IF;
  ELSE
    v_outcome_id := NULL;
  END IF;

  -- založ blok
  INSERT INTO template_blocks (template_id, block_index, block_type, match_id, market_outcome_id)
  VALUES (p_template_id, v_block_index, p_block_type, NULL, v_outcome_id)
  RETURNING id INTO v_block_id;

  -- přenes max 3 zápasy do bloku
  INSERT INTO template_block_matches (block_id, match_id, match_order)
  SELECT v_block_id, si.match_id,
         ROW_NUMBER() OVER (ORDER BY si.id) AS match_order
  FROM selection_items si
  WHERE si.selection_id = p_selection_id
  ORDER BY si.id
  LIMIT 3;

  -- volitelně: vyčisti selection (ať je připraven na další blok)
  DELETE FROM selection_items WHERE selection_id = p_selection_id;

  RETURN v_block_id;
END;
$$ LANGUAGE plpgsql;
