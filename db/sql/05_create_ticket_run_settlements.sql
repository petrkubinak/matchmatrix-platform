CREATE TABLE IF NOT EXISTS public.ticket_run_settlements (

    run_id BIGINT NOT NULL,
    ticket_index INTEGER NOT NULL,

    matches_count INTEGER,
    hits_count INTEGER,
    miss_count INTEGER,
    void_count INTEGER,
    pending_count INTEGER,

    total_odd NUMERIC,

    ticket_result_status TEXT,

    settled_at TIMESTAMPTZ DEFAULT now(),

    PRIMARY KEY (run_id, ticket_index)
);

CREATE INDEX IF NOT EXISTS idx_ticket_run_settlements_run
ON public.ticket_run_settlements(run_id);