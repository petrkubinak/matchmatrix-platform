-- 470_create_v_ticket_pattern_settlement_source.sql
-- Zdroj pro budoucí settlement patternů
-- Zatím předpokládá stake 100 na tiket, protože přesně s tím teď generujeme summary.
-- Skutečný settlement status zatím není dopočítán, ale struktura už je připravena.

CREATE OR REPLACE VIEW public.v_ticket_pattern_settlement_source AS
SELECT
    thb.id AS ticket_history_id,
    thb.run_id,
    thb.ticket_index,
    thb.pattern_id,
    thb.pattern_code,
    thb.created_at,

    100::numeric(18,4) AS stake_amount,
    thb.total_odd,
    thb.probability,

    NULL::text AS settlement_status,      -- WIN / LOSS / VOID / PENDING
    NULL::numeric(18,4) AS return_amount, -- po settlementu
    NULL::numeric(18,4) AS profit_loss    -- po settlementu

FROM public.ticket_history_base thb
JOIN public.v_ticket_pattern_history_quality q
  ON q.pattern_id = thb.pattern_id
 AND q.pattern_code = thb.pattern_code
WHERE q.history_quality = 'NORMALIZED';