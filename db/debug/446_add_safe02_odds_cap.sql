-- 446_add_safe02_odds_cap.sql
-- Cíl:
-- omezit SAFE_02 tak, aby nebyl extrémně agresivní
-- a vracel jen rozumnější kombinace

-- Doporučený první soft limit:
-- max celkový kurz tiketu <= 40

WITH ranked AS (
    SELECT
        gt.run_id,
        gt.ticket_index,
        t.total_odd
    FROM public.mm_ui_run_tickets(118) t
    JOIN public.generated_tickets gt
      ON gt.run_id = t.run_id
     AND gt.ticket_index = t.ticket_index
    WHERE t.total_odd > 40
)
SELECT *
FROM ranked
ORDER BY total_odd DESC, ticket_index;

-- Kontrolní souhrn:
SELECT
    COUNT(*) AS tickets_over_40,
    MIN(total_odd) AS min_odd_over_40,
    MAX(total_odd) AS max_odd_over_40
FROM public.mm_ui_run_tickets(118)
WHERE total_odd > 40;

-- Referenční distribuce:
SELECT
    ticket_index,
    total_odd
FROM public.mm_ui_run_tickets(118)
ORDER BY total_odd DESC, ticket_index;