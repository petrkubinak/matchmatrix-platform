-- 315_create_ticket_history_base.sql
-- Základní historie tiketů pro budoucí predikce a vyhodnocení podobných kombinací

CREATE TABLE IF NOT EXISTS public.ticket_history_base (
    id bigserial PRIMARY KEY,

    run_id bigint,
    ticket_index integer NOT NULL,

    created_at timestamptz NOT NULL DEFAULT now(),
    settled_at timestamptz NULL,

    source_system text NOT NULL DEFAULT 'ticket_studio',

    ticket_size integer NULL,
    total_odd numeric(12,4) NULL,
    stake numeric(12,2) NULL,
    possible_win numeric(12,2) NULL,

    probability numeric(12,6) NULL,

    cnt_home integer NULL,
    cnt_draw integer NULL,
    cnt_away integer NULL,

    outcome_signature text NULL,
    odd_band text NULL,

    is_hit boolean NULL,
    profit_amount numeric(12,2) NULL,
    roi_percent numeric(12,2) NULL,

    ticket_payload jsonb NULL,

    notes text NULL
);

CREATE INDEX IF NOT EXISTS idx_ticket_history_base_run_id
ON public.ticket_history_base (run_id);

CREATE INDEX IF NOT EXISTS idx_ticket_history_base_ticket_index
ON public.ticket_history_base (ticket_index);

CREATE INDEX IF NOT EXISTS idx_ticket_history_base_signature
ON public.ticket_history_base (ticket_size, odd_band, cnt_home, cnt_draw, cnt_away);

CREATE INDEX IF NOT EXISTS idx_ticket_history_base_created_at
ON public.ticket_history_base (created_at);