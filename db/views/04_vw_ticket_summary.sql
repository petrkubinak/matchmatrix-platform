CREATE OR REPLACE VIEW public.vw_ticket_summary AS
WITH item_base AS (
    SELECT
        vtsd.run_id,
        vtsd.ticket_index,
        vtsd.match_id,
        vtsd.market_outcome_id,
        vtsd.item_result_status
    FROM public.vw_ticket_settlement_detail vtsd
),
item_odds AS (
    SELECT
        ib.run_id,
        ib.ticket_index,
        ib.match_id,
        ib.market_outcome_id,
        ib.item_result_status,
        gr.bookmaker_id,
        o.odd_value
    FROM item_base ib
    JOIN public.generated_runs gr
      ON gr.id = ib.run_id
    LEFT JOIN public.odds o
      ON o.match_id = ib.match_id
     AND o.market_outcome_id = ib.market_outcome_id
     AND o.bookmaker_id = gr.bookmaker_id
),
agg AS (
    SELECT
        io.run_id,
        io.ticket_index,
        COUNT(*)::integer AS matches_count,
        COUNT(*) FILTER (WHERE io.item_result_status = 'hit')::integer AS hits_count,
        COUNT(*) FILTER (WHERE io.item_result_status = 'miss')::integer AS miss_count,
        COUNT(*) FILTER (WHERE io.item_result_status = 'void')::integer AS void_count,
        COUNT(*) FILTER (WHERE io.item_result_status = 'pending')::integer AS pending_count,

        CASE
            WHEN COUNT(*) FILTER (WHERE io.odd_value IS NULL) > 0 THEN NULL
            ELSE ROUND(EXP(SUM(LN(io.odd_value)))::numeric, 4)
        END AS total_odd
    FROM item_odds io
    GROUP BY io.run_id, io.ticket_index
)
SELECT
    a.run_id,
    a.ticket_index,
    a.matches_count,
    a.hits_count,
    a.miss_count,
    a.void_count,
    a.pending_count,
    a.total_odd,

    CASE
        WHEN a.pending_count > 0 THEN 'pending'
        WHEN a.miss_count > 0 THEN 'miss'
        WHEN a.hits_count > 0 AND a.void_count > 0 THEN 'partial'
        WHEN a.hits_count = a.matches_count THEN 'hit'
        WHEN a.void_count = a.matches_count THEN 'void'
        ELSE 'pending'
    END AS ticket_result_status

FROM agg a
ORDER BY a.run_id, a.ticket_index;