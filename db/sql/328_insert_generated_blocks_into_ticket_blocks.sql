-- 328_insert_generated_blocks_into_ticket_blocks.sql
-- Převod bloků z generated_* do ticket_blocks
-- ticket_blocks používá: block_code + sort_order

INSERT INTO public.ticket_blocks (
    ticket_id,
    block_code,
    sort_order,
    created_at
)
SELECT
    t.id AS ticket_id,
    CASE gtb.block_index
        WHEN 1 THEN 'A'
        WHEN 2 THEN 'B'
        WHEN 3 THEN 'C'
        ELSE 'B' || gtb.block_index::text
    END AS block_code,
    gtb.block_index AS sort_order,
    now() AS created_at
FROM public.tickets t
JOIN public.generated_runs gr
    ON t.note = 'imported from generated_run_id=' || gr.id
JOIN (
    SELECT DISTINCT run_id, block_index
    FROM public.generated_ticket_blocks
) gtb
    ON gtb.run_id = gr.id
WHERE gr.id = :p_run_id
  AND NOT EXISTS (
      SELECT 1
      FROM public.ticket_blocks tb
      WHERE tb.ticket_id = t.id
        AND tb.sort_order = gtb.block_index
  )
ORDER BY gtb.block_index;