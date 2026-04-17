-- 318_select_ticket_history_prediction.sql
-- Vrací historickou predikci pro konkrétní tiket

WITH current_ticket AS (
    SELECT
        gt.run_id,
        gt.ticket_index,
        COALESCE(jsonb_array_length(gt.snapshot -> 'blocks'), 0) AS ticket_size,

        COUNT(*) FILTER (WHERE blk.code = '1') AS cnt_home,
        COUNT(*) FILTER (WHERE blk.code = 'X') AS cnt_draw,
        COUNT(*) FILTER (WHERE blk.code = '2') AS cnt_away,

        STRING_AGG(COALESCE(blk.code, '?'), '' ORDER BY COALESCE(blk.code, '?')) AS outcome_signature
    FROM public.generated_tickets gt
    LEFT JOIN LATERAL (
        SELECT b ->> 'code' AS code
        FROM jsonb_array_elements(COALESCE(gt.snapshot -> 'blocks', '[]'::jsonb)) b
    ) blk ON TRUE
    WHERE gt.run_id = :run_id
      AND gt.ticket_index = :ticket_index
    GROUP BY gt.run_id, gt.ticket_index, gt.snapshot
),

matched_history AS (
    SELECT h.*
    FROM public.v_ticket_history_summary h
    JOIN current_ticket ct
      ON h.ticket_size = ct.ticket_size
     AND h.cnt_home = ct.cnt_home
     AND h.cnt_draw = ct.cnt_draw
     AND h.cnt_away = ct.cnt_away
)

SELECT
    ct.ticket_size,
    ct.cnt_home,
    ct.cnt_draw,
    ct.cnt_away,

    mh.sample_size,
    mh.avg_probability,
    mh.hit_rate,
    mh.avg_profit,
    mh.avg_roi,

    CASE
        WHEN mh.sample_size IS NULL OR mh.sample_size < 5 THEN 'Málo dat'
        WHEN mh.hit_rate >= 0.60 THEN 'Historicky silné'
        WHEN mh.hit_rate >= 0.45 THEN 'Historicky průměrné'
        ELSE 'Historicky slabší'
    END AS history_prediction

FROM current_ticket ct
LEFT JOIN matched_history mh ON TRUE;