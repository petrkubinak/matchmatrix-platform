ROLLBACK;
BEGIN;

-- =========================================================
-- 103_create_coach_provider_map.sql
-- Provider map pro trenéry
-- Jen nová tabulka + indexy, nic nepřepisuje
-- =========================================================

CREATE TABLE IF NOT EXISTS public.coach_provider_map (
    id                  BIGSERIAL PRIMARY KEY,
    coach_id            BIGINT NOT NULL,
    provider            TEXT NOT NULL,
    provider_coach_id   TEXT NOT NULL,
    confidence          NUMERIC(5,2) NOT NULL DEFAULT 1.00,
    source              TEXT NOT NULL DEFAULT 'provider_coach_map',
    is_primary          BOOLEAN NOT NULL DEFAULT FALSE,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_coach_provider_map UNIQUE (provider, provider_coach_id),
    CONSTRAINT fk_coach_provider_map_coach
        FOREIGN KEY (coach_id) REFERENCES public.coaches(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_coach_provider_map_coach_id
    ON public.coach_provider_map (coach_id);

CREATE INDEX IF NOT EXISTS idx_coach_provider_map_provider
    ON public.coach_provider_map (provider, provider_coach_id);

COMMIT;