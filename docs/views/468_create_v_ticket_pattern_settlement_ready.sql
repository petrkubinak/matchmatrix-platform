-- 468_create_v_ticket_pattern_settlement_ready.sql
-- Settlement-ready základ pro patterny tiketů
-- Zatím bez skutečného win/loss settlementu.
-- Připravuje čistý podklad pro budoucí ROI a hit-rate.

CREATE OR REPLACE VIEW public.v_ticket_pattern_settlement_ready AS
SELECT
    thb.pattern_id,
    thb.pattern_code,

    COUNT(*) AS tickets_count,

    MIN(thb.created_at) AS first_seen_at,
    MAX(thb.created_at) AS last_seen_at,

    AVG(thb.ticket_size::numeric) AS avg_ticket_size,
    AVG(thb.total_odd) AS avg_total_odd,
    AVG(thb.probability) AS avg_probability,

    SUM(thb.probability * thb.total_odd) AS expected_value_sum,
    AVG(thb.probability * thb.total_odd) AS expected_value_avg,

    CASE
        WHEN AVG(thb.probability * thb.total_odd) >= 1 THEN TRUE
        ELSE FALSE
    END AS is_ev_positive_model
FROM public.ticket_history_base thb
JOIN public.v_ticket_pattern_history_quality q
  ON q.pattern_id = thb.pattern_id
 AND q.pattern_code = thb.pattern_code
WHERE q.history_quality = 'NORMALIZED'
GROUP BY
    thb.pattern_id,
    thb.pattern_code;