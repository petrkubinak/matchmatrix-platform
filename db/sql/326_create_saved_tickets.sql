-- 326_create_saved_tickets.sql
-- Trvalé uložení vybraných tiketů
-- generated_* = výpočetní vrstva
-- saved_tickets = finální uložené tikety

CREATE TABLE IF NOT EXISTS public.saved_tickets (
    id bigserial PRIMARY KEY,
    saved_ticket_no bigserial NOT NULL UNIQUE,   -- posloupná uživatelská řada
    user_id bigint NULL,                         -- zatím NULL, později web uživatel
    generated_run_id bigint NOT NULL,
    ticket_index integer NOT NULL,

    source_system text NOT NULL DEFAULT 'ticket_studio',
    status text NOT NULL DEFAULT 'saved',        -- saved / submitted / settled / cancelled

    probability numeric(12,6) NULL,
    total_odd numeric(12,4) NULL,
    stake numeric(12,2) NULL,
    possible_win numeric(12,2) NULL,

    ticket_payload jsonb NULL,                   -- finální snapshot tiketu
    note text NULL,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT uq_saved_tickets_run_ticket UNIQUE (generated_run_id, ticket_index)
);

CREATE INDEX IF NOT EXISTS ix_saved_tickets_user_id
    ON public.saved_tickets (user_id);

CREATE INDEX IF NOT EXISTS ix_saved_tickets_generated_run_id
    ON public.saved_tickets (generated_run_id);

CREATE INDEX IF NOT EXISTS ix_saved_tickets_status
    ON public.saved_tickets (status);

CREATE INDEX IF NOT EXISTS ix_saved_tickets_created_at
    ON public.saved_tickets (created_at DESC);