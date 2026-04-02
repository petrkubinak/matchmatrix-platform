-- 465_audit_pattern_fix5_bl2_1_1_t7.sql
-- Audit historického patternu FIX5_BL2_1_1_MARKET_1_SINGLE_SPORT_1_T7

-- 1) Souhrn runů
SELECT
    thb.run_id,
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
WHERE thb.pattern_code = 'FIX5_BL2_1_1_MARKET_1_SINGLE_SPORT_1_T7'
GROUP BY thb.run_id
ORDER BY thb.run_id DESC;

-- 2) Vazba na generation runs / strategy
SELECT
    thb.run_id,
    tgr.id AS generation_run_id,
    tgr.strategy_code,
    tgr.requested_matches_count,
    tgr.generated_candidates_count,
    tgr.generated_variants_count,
    tgr.created_at AS generation_created_at
FROM public.ticket_history_base thb
LEFT JOIN public.ticket_generation_runs tgr
  ON (tgr.result_json->>'run_id')::bigint = thb.run_id
WHERE thb.pattern_code = 'FIX5_BL2_1_1_MARKET_1_SINGLE_SPORT_1_T7'
GROUP BY
    thb.run_id,
    tgr.id,
    tgr.strategy_code,
    tgr.requested_matches_count,
    tgr.generated_candidates_count,
    tgr.generated_variants_count,
    tgr.created_at
ORDER BY thb.run_id DESC;

-- 3) Kontrola ticket_size anomálií
SELECT
    thb.run_id,
    thb.ticket_index,
    thb.ticket_size,
    thb.total_odd,
    thb.probability,
    thb.created_at
FROM public.ticket_history_base thb
WHERE thb.pattern_code = 'FIX5_BL2_1_1_MARKET_1_SINGLE_SPORT_1_T7'
  AND (thb.ticket_size IS NULL OR thb.ticket_size <= 0 OR thb.ticket_size > 7)
ORDER BY thb.run_id DESC, thb.ticket_index;

-- 4) Rozdělení ticket_size
SELECT
    thb.ticket_size,
    COUNT(*) AS rows_count
FROM public.ticket_history_base thb
WHERE thb.pattern_code = 'FIX5_BL2_1_1_MARKET_1_SINGLE_SPORT_1_T7'
GROUP BY thb.ticket_size
ORDER BY thb.ticket_size;