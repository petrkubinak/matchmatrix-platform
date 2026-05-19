CREATE OR REPLACE VIEW public.vw_generated_ticket_matches AS
WITH variable_items AS (
    SELECT
        gtb.run_id,
        gtb.ticket_index,
        'block'::text AS source_type,
        gtb.block_index,
        tbm.match_id,
        tbm.market_id,
        gtb.market_outcome_id
    FROM public.generated_ticket_blocks gtb
    JOIN public.generated_runs gr
      ON gr.id = gtb.run_id
    JOIN public.template_block_matches tbm
      ON tbm.template_id = gr.template_id
     AND tbm.block_index = gtb.block_index
),
fixed_items AS (
    SELECT
        gt.run_id,
        gt.ticket_index,
        'fixed'::text AS source_type,
        NULL::integer AS block_index,
        gtf.match_id,
        tfp.market_id,
        gtf.market_outcome_id
    FROM public.generated_tickets gt
    JOIN public.generated_ticket_fixed gtf
      ON gtf.run_id = gt.run_id
    JOIN public.generated_runs gr
      ON gr.id = gt.run_id
    JOIN public.template_fixed_picks tfp
      ON tfp.template_id = gr.template_id
     AND tfp.match_id = gtf.match_id
     AND tfp.market_outcome_id = gtf.market_outcome_id
)
SELECT
    x.run_id,
    x.ticket_index,
    x.source_type,
    x.block_index,
    x.match_id,
    x.market_id,
    x.market_outcome_id
FROM (
    SELECT * FROM variable_items
    UNION ALL
    SELECT * FROM fixed_items
) x;