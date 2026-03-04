CREATE OR REPLACE FUNCTION trg_check_max_variable_blocks()
RETURNS trigger AS $$
DECLARE
  v_limit INT;
  v_count INT;
  v_template_id INT;
BEGIN
  v_template_id := NEW.template_id;

  -- zjisti limit z templates
  SELECT max_variable_blocks INTO v_limit
  FROM templates
  WHERE id = v_template_id;

  IF v_limit IS NULL THEN
    v_limit := 3; -- fallback
  END IF;

  -- pokud nový řádek není VARIABLE, nic neřeš
  IF NEW.block_type <> 'VARIABLE' THEN
    RETURN NEW;
  END IF;

  -- spočti VARIABLE bloky v template (bez aktuálního řádku při UPDATE)
  SELECT COUNT(*) INTO v_count
  FROM template_blocks
  WHERE template_id = v_template_id
    AND block_type = 'VARIABLE'
    AND (TG_OP = 'INSERT' OR id <> NEW.id);

  IF v_count >= v_limit THEN
    RAISE EXCEPTION
      'Template % already has % VARIABLE blocks (limit=%)',
      v_template_id, v_count, v_limit;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
