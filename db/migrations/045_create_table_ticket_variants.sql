BEGIN;

CREATE TABLE IF NOT EXISTS public.ticket_variants (
    id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL REFERENCES public.tickets(id) ON DELETE CASCADE,

    variant_no INT NOT NULL, -- 1..27

    total_matches_count INT NOT NULL DEFAULT 0,
    total_odds NUMERIC(12,4) NULL,
    probability NUMERIC(12,8) NULL,
    expected_value NUMERIC(14,8) NULL,

    hit_result TEXT NULL,     -- pending / hit / miss / void / partial
    settled_at TIMESTAMPTZ NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_ticket_variants_ticket_variant_no UNIQUE (ticket_id, variant_no),
    CONSTRAINT chk_ticket_variants_variant_no CHECK (variant_no BETWEEN 1 AND 27)
);

CREATE INDEX IF NOT EXISTS ix_ticket_variants_ticket_id
    ON public.ticket_variants(ticket_id);

CREATE INDEX IF NOT EXISTS ix_ticket_variants_probability
    ON public.ticket_variants(probability DESC);

COMMIT;