BEGIN;

CREATE TABLE IF NOT EXISTS public.ticket_generation_runs (
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT NULL REFERENCES public.users(id) ON DELETE SET NULL,
    strategy_code TEXT NULL,

    requested_matches_count INT NULL,
    generated_candidates_count INT NULL,
    generated_variants_count INT NULL,

    filters_json JSONB NULL,
    result_json JSONB NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_ticket_generation_runs_user_id
    ON public.ticket_generation_runs(user_id);

CREATE INDEX IF NOT EXISTS ix_ticket_generation_runs_created_at
    ON public.ticket_generation_runs(created_at DESC);

COMMIT;