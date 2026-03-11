BEGIN;

CREATE TABLE IF NOT EXISTS public.tickets (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NULL REFERENCES public.users(id) ON DELETE SET NULL,

    ticket_code TEXT NULL,
    strategy_code TEXT NULL,

    constants_count INT NOT NULL DEFAULT 0,
    blocks_count INT NOT NULL DEFAULT 0,
    variants_generated INT NOT NULL DEFAULT 0,

    source_type TEXT NOT NULL DEFAULT 'manual', -- manual / auto / hybrid
    status TEXT NOT NULL DEFAULT 'draft',       -- draft / generated / settled / cancelled

    note TEXT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_tickets_blocks_count CHECK (blocks_count BETWEEN 0 AND 3),
    CONSTRAINT chk_tickets_variants_generated CHECK (variants_generated BETWEEN 0 AND 27)
);

CREATE INDEX IF NOT EXISTS ix_tickets_user_id
    ON public.tickets(user_id);

CREATE INDEX IF NOT EXISTS ix_tickets_status
    ON public.tickets(status);

CREATE INDEX IF NOT EXISTS ix_tickets_created_at
    ON public.tickets(created_at DESC);

COMMIT;