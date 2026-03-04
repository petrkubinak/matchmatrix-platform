CREATE OR REPLACE FUNCTION check_max_3_matches_per_block()
RETURNS trigger AS $$
DECLARE
  v_cnt INT;
BEGIN
  SELECT COUNT(*) INTO v_cnt
  FROM template_block_matches
  WHERE block_id = NEW.block_id;

  IF v_cnt >= 3 THEN
    RAISE EXCEPTION 'Block % already has 3 matches', NEW.block_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_max_3_matches_per_block ON template_block_matches;

CREATE TRIGGER trg_max_3_matches_per_block
BEFORE INSERT ON template_block_matches
FOR EACH ROW
EXECUTE FUNCTION check_max_3_matches_per_block();
