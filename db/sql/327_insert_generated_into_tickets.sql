-- 327_insert_generated_into_tickets.sql
-- Převod generated_run → tickets (hlavička)

INSERT INTO public.tickets (
    user_id,
    ticket_code,
    strategy_code,
    constants_count,
    blocks_count,
    variants_generated,
    source_type,
    status,
    note
)
SELECT
    NULL::bigint AS user_id,

    -- jednoduchý unikátní kód
    'T-' || gr.id || '-' || NOW()::timestamp::date AS ticket_code,

    'AUTO_V1' AS strategy_code,

    0 AS constants_count,

    COUNT(DISTINCT gtb.block_index) AS blocks_count,

    COUNT(DISTINCT gt.ticket_index) AS variants_generated,

    'generated' AS source_type,

    'draft' AS status,

    'imported from generated_run_id=' || gr.id AS note

FROM public.generated_runs gr
JOIN public.generated_tickets gt
    ON gt.run_id = gr.id
LEFT JOIN public.generated_ticket_blocks gtb
    ON gtb.run_id = gt.run_id
   AND gtb.ticket_index = gt.ticket_index

WHERE gr.id = :p_run_id

GROUP BY gr.id
RETURNING id;