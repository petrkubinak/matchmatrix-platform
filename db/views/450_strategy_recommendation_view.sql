-- 450_strategy_recommendation_view.sql
-- Doporučená strategie z posledních běhů

CREATE OR REPLACE VIEW public.v_strategy_recommendation AS
WITH latest_per_strategy AS (
    SELECT
        vsc.*,
        ROW_NUMBER() OVER (
            PARTITION BY vsc.strategy_code
            ORDER BY vsc.generation_run_id DESC
        ) AS rn
    FROM public.v_strategy_comparison vsc
),
latest_only AS (
    SELECT *
    FROM latest_per_strategy
    WHERE rn = 1
),
scored AS (
    SELECT
        lo.*,
        ROW_NUMBER() OVER (
            ORDER BY lo.expected_value_sum DESC, lo.avg_probability DESC
        ) AS recommendation_rank
    FROM latest_only lo
)
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
    CASE
        WHEN recommendation_rank = 1 THEN TRUE
        ELSE FALSE
    END AS is_recommended
FROM scored
ORDER BY recommendation_rank;