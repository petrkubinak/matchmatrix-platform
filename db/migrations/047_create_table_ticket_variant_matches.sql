BEGIN;

CREATE TABLE IF NOT EXISTS public.ticket_variant_matches (
    id BIGSERIAL PRIMARY KEY,
    variant_id BIGINT NOT NULL REFERENCES public.ticket_variants(id) ON DELETE CASCADE,
    match_id BIGINT NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,

    source_type TEXT NOT NULL, -- constant / block
    block_id BIGINT NULL REFERENCES public.ticket_blocks(id) ON DELETE SET NULL,

    market_id BIGINT NULL REFERENCES public.markets(id) ON DELETE SET NULL,
    outcome_code TEXT NOT NULL, -- 1 / 0 / 2

    bookmaker_id BIGINT NULL REFERENCES public.bookmakers(id) ON DELETE SET NULL,
    bookmaker_odds NUMERIC(10,4) NULL,

    model_probability NUMERIC(10,6) NULL,
    expected_value NUMERIC(12,6) NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_ticket_variant_matches_source_type CHECK (source_type IN ('constant','block')),
    CONSTRAINT chk_ticket_variant_matches_outcome CHECK (outcome_code IN ('1','0','2')),
    CONSTRAINT uq_ticket_variant_matches UNIQUE (variant_id, match_id)
);

CREATE INDEX IF NOT EXISTS ix_ticket_variant_matches_variant_id
    ON public.ticket_variant_matches(variant_id);

CREATE INDEX IF NOT EXISTS ix_ticket_variant_matches_match_id
    ON public.ticket_variant_matches(match_id);

COMMIT;