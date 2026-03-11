BEGIN;

CREATE TABLE IF NOT EXISTS public.ticket_block_matches (
    id BIGSERIAL PRIMARY KEY,
    block_id BIGINT NOT NULL REFERENCES public.ticket_blocks(id) ON DELETE CASCADE,
    match_id BIGINT NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,

    market_id BIGINT NULL REFERENCES public.markets(id) ON DELETE SET NULL,

    bookmaker_id BIGINT NULL REFERENCES public.bookmakers(id) ON DELETE SET NULL,
    bookmaker_odds NUMERIC(10,4) NULL,

    prob_1 NUMERIC(10,6) NULL,
    prob_0 NUMERIC(10,6) NULL,
    prob_2 NUMERIC(10,6) NULL,

    sort_order INT NOT NULL DEFAULT 1,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_ticket_block_matches UNIQUE (block_id, match_id),
    CONSTRAINT chk_ticket_block_matches_prob_1 CHECK (prob_1 IS NULL OR (prob_1 >= 0 AND prob_1 <= 1)),
    CONSTRAINT chk_ticket_block_matches_prob_0 CHECK (prob_0 IS NULL OR (prob_0 >= 0 AND prob_0 <= 1)),
    CONSTRAINT chk_ticket_block_matches_prob_2 CHECK (prob_2 IS NULL OR (prob_2 >= 0 AND prob_2 <= 1))
);

CREATE INDEX IF NOT EXISTS ix_ticket_block_matches_block_id
    ON public.ticket_block_matches(block_id);

CREATE INDEX IF NOT EXISTS ix_ticket_block_matches_match_id
    ON public.ticket_block_matches(match_id);

COMMIT;