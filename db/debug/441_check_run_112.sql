-- 441_check_run_112.sql
-- Kontrola AUTO SAFE_03 runu 112

SELECT
    gr.id AS run_id,
    gr.template_id,
    gr.bookmaker_id,
    gr.created_at,
    gr.run_probability,
    COUNT(gt.id) AS generated_tickets_count
FROM public.generated_runs gr
LEFT JOIN public.generated_tickets gt
       ON gt.run_id = gr.id
WHERE gr.id = 112
GROUP BY
    gr.id, gr.template_id, gr.bookmaker_id, gr.created_at, gr.run_probability;

SELECT
    gt.id,
    gt.run_id,
    gt.ticket_index,
    gt.probability,
    gt.is_blocked,
    gt.snapshot
FROM public.generated_tickets gt
WHERE gt.run_id = 112
ORDER BY gt.ticket_index;