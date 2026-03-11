BEGIN;

CREATE TABLE IF NOT EXISTS public.ticket_pattern_stats (
    id BIGSERIAL PRIMARY KEY,

    pattern_code TEXT NOT NULL, -- např. CONST2_BLK3_MC7
    matches_count INT NOT NULL,
    constants_count INT NOT NULL,
    blocks_count INT NOT NULL,

    avg_total_odds NUMERIC(12,4) NULL,
    avg_probability NUMERIC(12,8) NULL,
    avg_expected_value NUMERIC(14,8) NULL,

    sample_size INT NOT NULL DEFAULT 0,
    hit_count INT NOT NULL DEFAULT 0,
    miss_count INT NOT NULL DEFAULT 0,
    void_count INT NOT NULL DEFAULT 0,

    hit_rate NUMERIC(10,6) NULL,
    roi NUMERIC(12,6) NULL,

    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_ticket_pattern_stats_pattern UNIQUE (pattern_code)
);

CREATE INDEX IF NOT EXISTS ix_ticket_pattern_stats_matches_count
    ON public.ticket_pattern_stats(matches_count);

COMMIT;