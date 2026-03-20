CREATE OR REPLACE VIEW ops.v_fb_test_phase1 AS
SELECT *
FROM ops.v_fb_test_execution_order
WHERE layer IN ('FB_TOP', 'FB_FD_CORE');