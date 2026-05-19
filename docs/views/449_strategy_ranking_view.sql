-- 449_strategy_ranking_view.sql
-- Jednoduché pořadí strategií podle výkonu

CREATE OR REPLACE VIEW public.v_strategy_ranking AS
WITH base AS (
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
        expected_value_sum
    FROM public.v_strategy_comparison
),
scored AS (
    SELECT
        b.*,
        RANK() OVER (
            ORDER BY b.expected_value_sum DESC, b.avg_probability DESC
        ) AS rank_by_ev,
        RANK() OVER (
            ORDER BY b.avg_probability DESC, b.expected_value_sum DESC
        ) AS rank_by_probability
    FROM base b
)
SELECT
    strategy_code,
    generation_run_id,
    run_id,
    tickets_count,
    avg_odd,
    avg_probability,
    expected_value_sum,
    rank_by_ev,
    rank_by_probability
FROM scored;