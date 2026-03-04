CREATE OR REPLACE FUNCTION check_max_variable_blocks()
RETURNS trigger AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM template_blocks
    WHERE template_id = NEW.template_id
      AND block_type = 'VARIABLE'
      AND (TG_OP = 'INSERT' OR id <> NEW.id);

    IF NEW.block_type = 'VARIABLE' AND v_count >= 3 THEN
        RAISE EXCEPTION
            'Template % already has 3 VARIABLE blocks',
            NEW.template_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
