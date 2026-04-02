-- 466_create_v_ticket_pattern_history_quality.sql
-- Kvalita a použitelnost pattern historie

CREATE OR REPLACE VIEW public.v_ticket_pattern_history_quality AS
SELECT
    thb.pattern_id,
    thb.pattern_code,
    COUNT(*) AS tickets_count,

    MIN(thb.created_at) AS first_seen_at,
    MAX(thb.created_at) AS last_seen_at,

    COUNT(*) FILTER (WHERE thb.ticket_size IS NULL OR thb.ticket_size <= 0) AS bad_ticket_size_rows,
    COUNT(*) FILTER (WHERE thb.total_odd IS NULL OR thb.total_odd <= 0) AS bad_total_odd_rows,
    COUNT(*) FILTER (WHERE thb.probability IS NULL OR thb.probability <= 0) AS bad_probability_rows,

    COUNT(DISTINCT thb.ticket_size) AS distinct_ticket_sizes,

    CASE
        WHEN
            COUNT(*) FILTER (WHERE thb.ticket_size IS NULL OR thb.ticket_size <= 0) > 0
            OR COUNT(*) FILTER (WHERE thb.total_odd IS NULL OR thb.total_odd <= 0) > 0
            OR COUNT(DISTINCT thb.ticket_size) > 1
        THEN 'LEGACY_MIXED'
        ELSE 'NORMALIZED'
    END AS history_quality
FROM public.ticket_history_base thb
WHERE thb.pattern_code IS NOT NULL
GROUP BY
    thb.pattern_id,
    thb.pattern_code;