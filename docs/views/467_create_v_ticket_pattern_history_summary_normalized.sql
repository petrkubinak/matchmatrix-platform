-- 467_create_v_ticket_pattern_history_summary_normalized.sql
-- Souhrn patternů jen nad normalizovanou historií

CREATE OR REPLACE VIEW public.v_ticket_pattern_history_summary_normalized AS
SELECT
    thb.pattern_id,
    thb.pattern_code,
    COUNT(*) AS tickets_count,

    MIN(thb.created_at) AS first_seen_at,
    MAX(thb.created_at) AS last_seen_at,

    MIN(thb.ticket_size) AS min_ticket_size,
    MAX(thb.ticket_size) AS max_ticket_size,
    AVG(thb.ticket_size::numeric) AS avg_ticket_size,

    MIN(thb.total_odd) AS min_total_odd,
    MAX(thb.total_odd) AS max_total_odd,
    AVG(thb.total_odd) AS avg_total_odd,

    MIN(thb.probability) AS min_probability,
    MAX(thb.probability) AS max_probability,
    AVG(thb.probability) AS avg_probability
FROM public.ticket_history_base thb
JOIN public.v_ticket_pattern_history_quality q
  ON q.pattern_id = thb.pattern_id
 AND q.pattern_code = thb.pattern_code
WHERE q.history_quality = 'NORMALIZED'
GROUP BY
    thb.pattern_id,
    thb.pattern_code;