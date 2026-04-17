-- 316_insert_ticket_history_from_generated.sql
-- Naplnění public.ticket_history_base z generated_tickets
-- Používá snapshot z generated_tickets a rozbalí snapshot->'blocks'

INSERT INTO public.ticket_history_base (
    run_id,
    ticket_index,
    created_at,
    source_system,
    ticket_size,
    total_odd,
    stake,
    possible_win,
    probability,
    cnt_home,
    cnt_draw,
    cnt_away,
    outcome_signature,
    odd_band,
    ticket_payload,
    notes
)
SELECT
    gt.run_id,
    gt.ticket_index,
    COALESCE(gr.created_at, now()) AS created_at,
    'ticket_studio' AS source_system,

    COALESCE(jsonb_array_length(gt.snapshot -> 'blocks'), 0) AS ticket_size,

    NULL::numeric(12,4) AS total_odd,
    NULL::numeric(12,2) AS stake,
    NULL::numeric(12,2) AS possible_win,

    gt.probability,

    COUNT(*) FILTER (WHERE blk.code = '1') AS cnt_home,
    COUNT(*) FILTER (WHERE blk.code = 'X') AS cnt_draw,
    COUNT(*) FILTER (WHERE blk.code = '2') AS cnt_away,

    STRING_AGG(COALESCE(blk.code, '?'), '' ORDER BY COALESCE(blk.code, '?')) AS outcome_signature,

    NULL::text AS odd_band,

    gt.snapshot AS ticket_payload,
    'seed from generated_tickets.snapshot' AS notes
FROM public.generated_tickets gt
LEFT JOIN public.generated_runs gr
    ON gr.id = gt.run_id
LEFT JOIN LATERAL (
    SELECT
        b ->> 'code' AS code
    FROM jsonb_array_elements(COALESCE(gt.snapshot -> 'blocks', '[]'::jsonb)) AS b
) blk
    ON TRUE
WHERE NOT EXISTS (
    SELECT 1
    FROM public.ticket_history_base thb
    WHERE thb.run_id = gt.run_id
      AND thb.ticket_index = gt.ticket_index
)
GROUP BY
    gt.run_id,
    gt.ticket_index,
    gr.created_at,
    gt.probability,
    gt.snapshot;