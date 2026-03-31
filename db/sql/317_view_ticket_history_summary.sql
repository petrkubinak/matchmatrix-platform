-- 317_view_ticket_history_summary.sql
-- Souhrn historie podobných tiketových kombinací

CREATE OR REPLACE VIEW public.v_ticket_history_summary AS
SELECT
    ticket_size,
    odd_band,
    cnt_home,
    cnt_draw,
    cnt_away,
    outcome_signature,
    COUNT(*) AS sample_size,
    ROUND(AVG(probability)::numeric, 4) AS avg_probability,
    ROUND(AVG(total_odd)::numeric, 4) AS avg_total_odd,
    ROUND(AVG(CASE WHEN is_hit IS TRUE THEN 1.0 ELSE 0.0 END)::numeric, 4) AS hit_rate,
    ROUND(AVG(COALESCE(profit_amount, 0))::numeric, 2) AS avg_profit,
    ROUND(AVG(COALESCE(roi_percent, 0))::numeric, 2) AS avg_roi
FROM public.ticket_history_base
GROUP BY
    ticket_size,
    odd_band,
    cnt_home,
    cnt_draw,
    cnt_away,
    outcome_signature;