-- 416_audit_auto_ticket_flow.sql
-- Audit připravenosti pro AUTO ticket generator
-- Cíl:
-- 1) zjistit, zda generated_runs -> ticket_history_base už reálně teče
-- 2) zkontrolovat source_system
-- 3) ověřit vazbu run_id + ticket_index
-- 4) připravit bezpečné oddělení AUTO/SYSTEM tiketů od budoucích user tiketů

-- =========================================================
-- 1) Kolik runů a tiketů máme v runtime vrstvě
-- =========================================================
SELECT 'generated_runs' AS bucket, COUNT(*) AS row_count FROM public.generated_runs
UNION ALL
SELECT 'generated_tickets', COUNT(*) FROM public.generated_tickets
UNION ALL
SELECT 'generated_ticket_blocks', COUNT(*) FROM public.generated_ticket_blocks
UNION ALL
SELECT 'ticket_history_base', COUNT(*) FROM public.ticket_history_base
UNION ALL
SELECT 'ticket_settlements', COUNT(*) FROM public.ticket_settlements
ORDER BY bucket;

-- =========================================================
-- 2) source_system v ticket_history_base
-- =========================================================
SELECT
    source_system,
    COUNT(*) AS row_count,
    MIN(created_at) AS first_created_at,
    MAX(created_at) AS last_created_at
FROM public.ticket_history_base
GROUP BY source_system
ORDER BY row_count DESC, source_system;

-- =========================================================
-- 3) Kontrola napojení generated_tickets -> ticket_history_base
--    přes run_id + ticket_index
-- =========================================================
SELECT
    COUNT(*) AS generated_ticket_rows,
    COUNT(thb.*) AS matched_history_rows,
    COUNT(*) - COUNT(thb.*) AS missing_in_history
FROM public.generated_tickets gt
LEFT JOIN public.ticket_history_base thb
       ON thb.run_id = gt.run_id
      AND thb.ticket_index = gt.ticket_index;

-- =========================================================
-- 4) Které generated_tickets ještě nejsou v historii
-- =========================================================
SELECT
    gt.run_id,
    gt.ticket_index,
    gt.probability,
    gr.template_id,
    gr.bookmaker_id,
    gr.created_at AS run_created_at
FROM public.generated_tickets gt
JOIN public.generated_runs gr
  ON gr.id = gt.run_id
LEFT JOIN public.ticket_history_base thb
       ON thb.run_id = gt.run_id
      AND thb.ticket_index = gt.ticket_index
WHERE thb.id IS NULL
ORDER BY gt.run_id DESC, gt.ticket_index
LIMIT 100;

-- =========================================================
-- 5) Posledních 50 history řádků
-- =========================================================
SELECT
    id,
    run_id,
    ticket_index,
    created_at,
    settled_at,
    source_system,
    ticket_size,
    total_odd,
    stake,
    possible_win,
    probability,
    is_hit,
    profit_amount,
    roi_percent
FROM public.ticket_history_base
ORDER BY created_at DESC, id DESC
LIMIT 50;

-- =========================================================
-- 6) Duplicity v history podle run_id + ticket_index
--    tohle musí být čisté
-- =========================================================
SELECT
    run_id,
    ticket_index,
    COUNT(*) AS dup_count
FROM public.ticket_history_base
GROUP BY run_id, ticket_index
HAVING COUNT(*) > 1
ORDER BY dup_count DESC, run_id DESC, ticket_index;

-- =========================================================
-- 7) Settlement coverage vůči history
-- =========================================================
SELECT
    COUNT(*) AS history_rows,
    COUNT(ts.*) AS matched_settlements,
    COUNT(*) - COUNT(ts.*) AS history_without_settlement
FROM public.ticket_history_base thb
LEFT JOIN public.ticket_settlements ts
       ON ts.ticket_id = thb.id;

-- =========================================================
-- 8) Přehled posledních generation runs
-- =========================================================
SELECT
    id,
    user_id,
    strategy_code,
    requested_matches_count,
    generated_candidates_count,
    generated_variants_count,
    created_at
FROM public.ticket_generation_runs
ORDER BY created_at DESC, id DESC
LIMIT 50;