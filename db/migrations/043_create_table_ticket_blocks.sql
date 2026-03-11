BEGIN;

CREATE TABLE IF NOT EXISTS public.ticket_blocks (
    id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL REFERENCES public.tickets(id) ON DELETE CASCADE,

    block_code TEXT NOT NULL,   -- A / B / C
    sort_order INT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_ticket_blocks_code CHECK (block_code IN ('A','B','C')),
    CONSTRAINT uq_ticket_blocks_ticket_code UNIQUE (ticket_id, block_code),
    CONSTRAINT uq_ticket_blocks_ticket_sort UNIQUE (ticket_id, sort_order)
);

CREATE INDEX IF NOT EXISTS ix_ticket_blocks_ticket_id
    ON public.ticket_blocks(ticket_id);

COMMIT;