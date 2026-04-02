-- 451_strategy_recommendation_current.sql
-- Vrací právě jednu aktuálně doporučenou strategii

CREATE OR REPLACE VIEW public.v_strategy_recommendation_current AS
SELECT
    strategy_code,
    generation_run_id,
    run_id,
    tickets_count,
    min_odd,
    max_odd,
    avg_odd,
    min_probability,
    max_probability,
    avg_probability,
    expected_value_sum,
    recommendation_rank,
    is_recommended
FROM public.v_strategy_recommendation
WHERE is_recommended = TRUE
ORDER BY recommendation_rank
LIMIT 1;