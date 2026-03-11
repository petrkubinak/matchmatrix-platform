BEGIN;

CREATE TABLE IF NOT EXISTS public.ticket_variant_features (
    id BIGSERIAL PRIMARY KEY,
    variant_id BIGINT NOT NULL REFERENCES public.ticket_variants(id) ON DELETE CASCADE,

    matches_count INT NOT NULL,
    constants_count INT NOT NULL,
    blocks_count INT NOT NULL,

    leagues_count INT NULL,
    avg_match_probability NUMERIC(12,8) NULL,
    min_match_probability NUMERIC(12,8) NULL,
    max_match_probability NUMERIC(12,8) NULL,

    avg_odds NUMERIC(12,4) NULL,
    min_odds NUMERIC(12,4) NULL,
    max_odds NUMERIC(12,4) NULL,

    total_odds NUMERIC(12,4) NULL,
    total_probability NUMERIC(12,8) NULL,
    total_expected_value NUMERIC(14,8) NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_ticket_variant_features UNIQUE (variant_id)
);

CREATE INDEX IF NOT EXISTS ix_ticket_variant_features_total_ev
    ON public.ticket_variant_features(total_expected_value DESC);

COMMIT;