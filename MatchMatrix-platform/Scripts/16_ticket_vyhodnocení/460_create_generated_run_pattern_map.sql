-- 460_create_generated_run_pattern_map.sql
-- Vazba generated run -> ticket pattern

CREATE TABLE IF NOT EXISTS public.generated_run_pattern_map (
    id bigserial PRIMARY KEY,
    run_id bigint NOT NULL UNIQUE,
    pattern_id bigint NOT NULL REFERENCES public.ticket_pattern_catalog(id),
    pattern_code text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);