-- 471_create_v_ticket_pattern_settlement_aggregate.sql
-- Agregační view pro budoucí plnění ticket_pattern_settlements

CREATE OR REPLACE VIEW public.v_ticket_pattern_settlement_aggregate AS
SELECT
    src.pattern_id,
    src.pattern_code,

    COUNT(*) FILTER (
        WHERE src.settlement_status IN ('WIN', 'LOSS', 'VOID')
    )::int AS settled_tickets_count,

    COUNT(*) FILTER (
        WHERE src.settlement_status = 'WIN'
    )::int AS won_tickets_count,

    COUNT(*) FILTER (
        WHERE src.settlement_status = 'LOSS'
    )::int AS lost_tickets_count,

    COUNT(*) FILTER (
        WHERE src.settlement_status = 'VOID'
    )::int AS void_tickets_count,

    COALESCE(SUM(src.stake_amount) FILTER (
        WHERE src.settlement_status IN ('WIN', 'LOSS', 'VOID')
    ), 0)::numeric(18,4) AS total_stake,

    COALESCE(SUM(src.return_amount) FILTER (
        WHERE src.settlement_status IN ('WIN', 'LOSS', 'VOID')
    ), 0)::numeric(18,4) AS total_return,

    COALESCE(SUM(src.profit_loss) FILTER (
        WHERE src.settlement_status IN ('WIN', 'LOSS', 'VOID')
    ), 0)::numeric(18,4) AS profit_loss,

    CASE
        WHEN COALESCE(SUM(src.stake_amount) FILTER (
            WHERE src.settlement_status IN ('WIN', 'LOSS', 'VOID')
        ), 0) > 0
        THEN
            COALESCE(SUM(src.profit_loss) FILTER (
                WHERE src.settlement_status IN ('WIN', 'LOSS', 'VOID')
            ), 0)
            /
            SUM(src.stake_amount) FILTER (
                WHERE src.settlement_status IN ('WIN', 'LOSS', 'VOID')
            )
        ELSE NULL
    END::numeric(18,6) AS roi,

    CASE
        WHEN COUNT(*) FILTER (
            WHERE src.settlement_status IN ('WIN', 'LOSS', 'VOID')
        ) > 0
        THEN
            COUNT(*) FILTER (WHERE src.settlement_status = 'WIN')::numeric
            /
            COUNT(*) FILTER (
                WHERE src.settlement_status IN ('WIN', 'LOSS', 'VOID')
            )::numeric
        ELSE NULL
    END::numeric(18,6) AS hit_rate,

    AVG(src.total_odd) FILTER (
        WHERE src.settlement_status = 'WIN'
    )::numeric(18,6) AS avg_winning_odd,

    MIN(src.created_at) FILTER (
        WHERE src.settlement_status IN ('WIN', 'LOSS', 'VOID')
    ) AS first_settled_at,

    MAX(src.created_at) FILTER (
        WHERE src.settlement_status IN ('WIN', 'LOSS', 'VOID')
    ) AS last_settled_at

FROM public.v_ticket_pattern_settlement_source src
GROUP BY
    src.pattern_id,
    src.pattern_code;