BEGIN;

CREATE TABLE IF NOT EXISTS public.ticket_settlements (
    id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL REFERENCES public.tickets(id) ON DELETE CASCADE,
    variant_id BIGINT NULL REFERENCES public.ticket_variants(id) ON DELETE CASCADE,

    stake NUMERIC(12,2) NULL,
    payout NUMERIC(12,2) NULL,
    profit_loss NUMERIC(12,2) NULL,

    result_status TEXT NOT NULL DEFAULT 'pending', -- pending / hit / miss / void / partial

    settled_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_ticket_settlements_result_status CHECK (result_status IN ('pending','hit','miss','void','partial'))
);

CREATE INDEX IF NOT EXISTS ix_ticket_settlements_ticket_id
    ON public.ticket_settlements(ticket_id);

CREATE INDEX IF NOT EXISTS ix_ticket_settlements_variant_id
    ON public.ticket_settlements(variant_id);

COMMIT;