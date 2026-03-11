BEGIN;

CREATE TABLE IF NOT EXISTS public.ticket_variant_block_choices (
    id BIGSERIAL PRIMARY KEY,
    variant_id BIGINT NOT NULL REFERENCES public.ticket_variants(id) ON DELETE CASCADE,
    block_id BIGINT NOT NULL REFERENCES public.ticket_blocks(id) ON DELETE CASCADE,

    chosen_outcome_code TEXT NOT NULL, -- 1 / 0 / 2

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_ticket_variant_block_choices_outcome CHECK (chosen_outcome_code IN ('1','0','2')),
    CONSTRAINT uq_ticket_variant_block_choices UNIQUE (variant_id, block_id)
);

CREATE INDEX IF NOT EXISTS ix_ticket_variant_block_choices_variant_id
    ON public.ticket_variant_block_choices(variant_id);

CREATE INDEX IF NOT EXISTS ix_ticket_variant_block_choices_block_id
    ON public.ticket_variant_block_choices(block_id);

COMMIT;