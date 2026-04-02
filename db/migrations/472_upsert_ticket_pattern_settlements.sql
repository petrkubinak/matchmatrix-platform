-- 472_upsert_ticket_pattern_settlements.sql
-- Upsert agregovaných settlement dat do finální tabulky

INSERT INTO public.ticket_pattern_settlements (
    pattern_id,
    pattern_code,
    settled_tickets_count,
    won_tickets_count,
    lost_tickets_count,
    void_tickets_count,
    total_stake,
    total_return,
    profit_loss,
    roi,
    hit_rate,
    avg_winning_odd,
    first_settled_at,
    last_settled_at,
    source_note
)
SELECT
    a.pattern_id,
    a.pattern_code,
    a.settled_tickets_count,
    a.won_tickets_count,
    a.lost_tickets_count,
    a.void_tickets_count,
    a.total_stake,
    a.total_return,
    a.profit_loss,
    a.roi,
    a.hit_rate,
    a.avg_winning_odd,
    a.first_settled_at,
    a.last_settled_at,
    'upsert from v_ticket_pattern_settlement_aggregate'
FROM public.v_ticket_pattern_settlement_aggregate a
ON CONFLICT (pattern_id) DO UPDATE
SET
    pattern_code = EXCLUDED.pattern_code,
    settled_tickets_count = EXCLUDED.settled_tickets_count,
    won_tickets_count = EXCLUDED.won_tickets_count,
    lost_tickets_count = EXCLUDED.lost_tickets_count,
    void_tickets_count = EXCLUDED.void_tickets_count,
    total_stake = EXCLUDED.total_stake,
    total_return = EXCLUDED.total_return,
    profit_loss = EXCLUDED.profit_loss,
    roi = EXCLUDED.roi,
    hit_rate = EXCLUDED.hit_rate,
    avg_winning_odd = EXCLUDED.avg_winning_odd,
    first_settled_at = EXCLUDED.first_settled_at,
    last_settled_at = EXCLUDED.last_settled_at,
    source_note = EXCLUDED.source_note,
    updated_at = now();