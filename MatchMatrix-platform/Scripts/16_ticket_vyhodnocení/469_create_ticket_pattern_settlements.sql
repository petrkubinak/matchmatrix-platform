-- 469_create_ticket_pattern_settlements.sql
-- Reálné vyhodnocení patternů tiketů

CREATE TABLE IF NOT EXISTS public.ticket_pattern_settlements (
    id bigserial PRIMARY KEY,
    pattern_id bigint NOT NULL REFERENCES public.ticket_pattern_catalog(id),
    pattern_code text NOT NULL,

    settled_tickets_count integer NOT NULL DEFAULT 0,
    won_tickets_count integer NOT NULL DEFAULT 0,
    lost_tickets_count integer NOT NULL DEFAULT 0,
    void_tickets_count integer NOT NULL DEFAULT 0,

    total_stake numeric(18,4) NOT NULL DEFAULT 0,
    total_return numeric(18,4) NOT NULL DEFAULT 0,
    profit_loss numeric(18,4) NOT NULL DEFAULT 0,
    roi numeric(18,6),

    hit_rate numeric(18,6),
    avg_winning_odd numeric(18,6),

    first_settled_at timestamptz,
    last_settled_at timestamptz,

    source_note text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_ticket_pattern_settlements_pattern UNIQUE (pattern_id)
);