BEGIN;

CREATE TABLE IF NOT EXISTS public.ticket_recommendation_feedback (
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT NULL REFERENCES public.users(id) ON DELETE SET NULL,
    ticket_id BIGINT NULL REFERENCES public.tickets(id) ON DELETE CASCADE,
    variant_id BIGINT NULL REFERENCES public.ticket_variants(id) ON DELETE CASCADE,

    feedback_type TEXT NOT NULL, -- shown / opened / accepted / rejected / played
    feedback_value NUMERIC(12,4) NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_ticket_recommendation_feedback_type
        CHECK (feedback_type IN ('shown','opened','accepted','rejected','played'))
);

CREATE INDEX IF NOT EXISTS ix_ticket_recommendation_feedback_user_id
    ON public.ticket_recommendation_feedback(user_id);

CREATE INDEX IF NOT EXISTS ix_ticket_recommendation_feedback_variant_id
    ON public.ticket_recommendation_feedback(variant_id);

COMMIT;