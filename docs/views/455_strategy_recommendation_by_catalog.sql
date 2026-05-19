-- 455_strategy_recommendation_by_catalog.sql
-- Doporučení strategie podle katalogu (family + ticket_type)

CREATE OR REPLACE VIEW public.v_strategy_recommendation_by_catalog AS
WITH base AS (
    SELECT
        vsc.*,
        tsc.strategy_family,
        tsc.ticket_type,
        tsc.risk_profile,
        tsc.is_test_only
    FROM public.v_strategy_comparison vsc
    JOIN public.ticket_strategy_catalog tsc
      ON tsc.strategy_code = vsc.strategy_code
    WHERE tsc.is_active = TRUE
),
latest_per_strategy AS (
    SELECT
        b.*,
        ROW_NUMBER() OVER (
            PARTITION BY b.strategy_code
            ORDER BY b.generation_run_id DESC
        ) AS rn
    FROM base b
),
latest_only AS (
    SELECT *
    FROM latest_per_strategy
    WHERE rn = 1
),
filtered AS (
    SELECT *
    FROM latest_only
    WHERE is_test_only = FALSE
),
ranked AS (
    SELECT
        f.*,
        ROW_NUMBER() OVER (
            PARTITION BY f.strategy_family, f.ticket_type
            ORDER BY f.expected_value_sum DESC, f.avg_probability DESC
        ) AS recommendation_rank
    FROM filtered f
)
SELECT
    strategy_family,
    ticket_type,
    strategy_code,
    generation_run_id,
    run_id,
    avg_odd,
    avg_probability,
    expected_value_sum,
    recommendation_rank,
    CASE
        WHEN recommendation_rank = 1 THEN TRUE
        ELSE FALSE
    END AS is_recommended
FROM ranked
ORDER BY strategy_family, ticket_type, recommendation_rank;