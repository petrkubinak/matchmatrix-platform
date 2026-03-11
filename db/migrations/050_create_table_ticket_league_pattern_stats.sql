BEGIN;

CREATE TABLE IF NOT EXISTS public.ticket_league_pattern_stats (
    id BIGSERIAL PRIMARY KEY,

    pattern_code TEXT NOT NULL,
    league_combo_key TEXT NOT NULL, -- např. EPL+SERIEA+CZ1

    sample_size INT NOT NULL DEFAULT 0,
    hit_rate NUMERIC(10,6) NULL,
    roi NUMERIC(12,6) NULL,

    avg_total_odds NUMERIC(12,4) NULL,
    avg_probability NUMERIC(12,8) NULL,

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_ticket_league_pattern_stats UNIQUE (pattern_code, league_combo_key)
);

CREATE INDEX IF NOT EXISTS ix_ticket_league_pattern_stats_pattern_code
    ON public.ticket_league_pattern_stats(pattern_code);

COMMIT;