-- 445_audit_auto_multi_run_last_batch.sql
-- Audit posledního AUTO MULTI RUN batch běhu
-- Runy z posledního potvrzeného batch:
-- AUTO_SAFE_01 = run_id 117
-- AUTO_SAFE_02 = run_id 118
-- AUTO_SAFE_03 = run_id 119

-- 1) Přehled generated_runs
SELECT
    gr.id AS run_id,
    gr.template_id,
    gr.bookmaker_id,
    gr.max_tickets,
    gr.min_probability,
    gr.run_probability,
    gr.created_at
FROM public.generated_runs gr
WHERE gr.id IN (117, 118, 119)
ORDER BY gr.id;

-- 2) Souhrn přes UI summary
SELECT *
FROM public.mm_ui_run_summary(117, 100);

SELECT *
FROM public.mm_ui_run_summary(118, 100);

SELECT *
FROM public.mm_ui_run_summary(119, 100);

-- 3) Počet ticketů v generated_tickets
SELECT
    gt.run_id,
    COUNT(*) AS tickets_count,
    MIN(gt.probability) AS min_probability,
    MAX(gt.probability) AS max_probability
FROM public.generated_tickets gt
WHERE gt.run_id IN (117, 118, 119)
GROUP BY gt.run_id
ORDER BY gt.run_id;

-- 4) Kontrola historie
SELECT
    thb.run_id,
    COUNT(*) AS history_rows,
    MIN(thb.total_odd) AS min_total_odd,
    MAX(thb.total_odd) AS max_total_odd,
    AVG(thb.total_odd) AS avg_total_odd,
    MIN(thb.probability) AS min_probability,
    MAX(thb.probability) AS max_probability
FROM public.ticket_history_base thb
WHERE thb.run_id IN (117, 118, 119)
GROUP BY thb.run_id
ORDER BY thb.run_id;

-- 5) Audit ticket_generation_runs
SELECT
    tgr.id AS generation_run_id,
    tgr.strategy_code,
    tgr.requested_matches_count,
    tgr.generated_candidates_count,
    tgr.generated_variants_count,
    tgr.filters_json,
    tgr.result_json,
    tgr.created_at
FROM public.ticket_generation_runs tgr
WHERE tgr.id IN (8, 9, 10)
ORDER BY tgr.id;

-- 6) Porovnání strategií v jedné tabulce
WITH s117 AS (
    SELECT * FROM public.mm_ui_run_summary(117, 100)
),
s118 AS (
    SELECT * FROM public.mm_ui_run_summary(118, 100)
),
s119 AS (
    SELECT * FROM public.mm_ui_run_summary(119, 100)
)
SELECT
    'AUTO_SAFE_01' AS strategy_code,
    run_id,
    tickets_count,
    total_stake,
    min_total_odd,
    max_total_odd,
    avg_total_odd,
    max_possible_win
FROM s117

UNION ALL

SELECT
    'AUTO_SAFE_02' AS strategy_code,
    run_id,
    tickets_count,
    total_stake,
    min_total_odd,
    max_total_odd,
    avg_total_odd,
    max_possible_win
FROM s118

UNION ALL

SELECT
    'AUTO_SAFE_03' AS strategy_code,
    run_id,
    tickets_count,
    total_stake,
    min_total_odd,
    max_total_odd,
    avg_total_odd,
    max_possible_win
FROM s119
ORDER BY strategy_code;