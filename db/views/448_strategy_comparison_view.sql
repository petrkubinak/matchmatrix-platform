-- 448_strategy_comparison_view.sql
-- Porovnání strategií SAFE_01 / SAFE_02 / SAFE_03

CREATE OR REPLACE VIEW public.v_strategy_comparison AS
SELECT
    tgr.strategy_code,
    tgr.id AS generation_run_id,
    (tgr.result_json->>'run_id')::bigint AS run_id,

    COUNT(thb.id) AS tickets_count,

    MIN(thb.total_odd) AS min_odd,
    MAX(thb.total_odd) AS max_odd,
    AVG(thb.total_odd) AS avg_odd,

    MIN(thb.probability) AS min_probability,
    MAX(thb.probability) AS max_probability,
    AVG(thb.probability) AS avg_probability,

    -- základ pro ROI (později)
    SUM(thb.probability * thb.total_odd) AS expected_value_sum

FROM public.ticket_generation_runs tgr
JOIN public.ticket_history_base thb
  ON thb.run_id = (tgr.result_json->>'run_id')::bigint

WHERE tgr.strategy_code LIKE 'AUTO_SAFE_%'

GROUP BY
    tgr.strategy_code,
    tgr.id,
    (tgr.result_json->>'run_id');