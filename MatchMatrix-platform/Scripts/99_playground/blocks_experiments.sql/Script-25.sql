CREATE TRIGGER trg_check_max_variable_blocks
BEFORE INSERT OR UPDATE ON template_blocks
FOR EACH ROW
EXECUTE FUNCTION check_max_variable_blocks();
