BEGIN;

CREATE TABLE IF NOT EXISTS public.ticket_constants (
    id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL REFERENCES public.tickets(id) ON DELETE CASCADE,
    match_id BIGINT NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,

    market_id BIGINT NULL REFERENCES public.markets(id) ON DELETE SET NULL,
    outcome_code TEXT NOT NULL, -- 1 / 0 / 2

    bookmaker_id BIGINT NULL REFERENCES public.bookmakers(id) ON DELETE SET NULL,
    bookmaker_odds NUMERIC(10,4) NULL,

    model_probability NUMERIC(10,6) NULL,
    expected_value NUMERIC(12,6) NULL,

    sort_order INT NOT NULL DEFAULT 1,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_ticket_constants_outcome CHECK (outcome_code IN ('1','0','2')),
    CONSTRAINT uq_ticket_constants_ticket_match UNIQUE (ticket_id, match_id)
);

CREATE INDEX IF NOT EXISTS ix_ticket_constants_ticket_id
    ON public.ticket_constants(ticket_id);

CREATE INDEX IF NOT EXISTS ix_ticket_constants_match_id
    ON public.ticket_constants(match_id);

COMMIT;