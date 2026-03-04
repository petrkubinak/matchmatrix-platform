DROP TRIGGER IF EXISTS check_max_variable_blocks ON template_blocks;

CREATE TRIGGER check_max_variable_blocks
BEFORE INSERT OR UPDATE ON template_blocks
FOR EACH ROW
EXECUTE FUNCTION trg_check_max_variable_blocks();
