ROLLBACK;
BEGIN;

-- =========================================================
-- 102_extend_existing_coach_core.sql
-- Rozšíření EXISTUJÍCÍ trenérské vrstvy
-- =========================================================

-- ---------------------------------------------------------
-- 1) public.coaches - rozšíření
-- ---------------------------------------------------------
ALTER TABLE public.coaches
    ADD COLUMN IF NOT EXISTS sport_id BIGINT,
    ADD COLUMN IF NOT EXISTS birth_place TEXT,
    ADD COLUMN IF NOT EXISTS birth_country TEXT,
    ADD COLUMN IF NOT EXISTS photo_url TEXT,
    ADD COLUMN IF NOT EXISTS nationality_code TEXT,
    ADD COLUMN IF NOT EXISTS external_slug TEXT,
    ADD COLUMN IF NOT EXISTS source_payload_hash TEXT,
    ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS retired_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS metadata JSONB NOT NULL DEFAULT '{}'::jsonb;

-- FK pokud chybí
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_coaches_sport_id'
    ) THEN
        ALTER TABLE public.coaches
        ADD CONSTRAINT fk_coaches_sport_id
        FOREIGN KEY (sport_id) REFERENCES public.sports(id);
    END IF;
END $$;

-- ---------------------------------------------------------
-- 2) public.team_coaches - historie trenérů
-- ---------------------------------------------------------
ALTER TABLE public.team_coaches
    ADD COLUMN IF NOT EXISTS valid_from DATE,
    ADD COLUMN IF NOT EXISTS valid_to DATE,
    ADD COLUMN IF NOT EXISTS is_current BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS source_provider TEXT,
    ADD COLUMN IF NOT EXISTS source_payload_hash TEXT,
    ADD COLUMN IF NOT EXISTS confidence NUMERIC(5,2) DEFAULT 1.00,
    ADD COLUMN IF NOT EXISTS notes TEXT;

-- ---------------------------------------------------------
-- 3) coach_provider_map (jen pokud není)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.coach_provider_map (
    id                  BIGSERIAL PRIMARY KEY,
    coach_id            BIGINT NOT NULL,
    provider            TEXT NOT NULL,
    provider_coach_id   TEXT NOT NULL,
    confidence          NUMERIC(5,2) NOT NULL DEFAULT 1.00,
    is_primary          BOOLEAN NOT NULL DEFAULT FALSE,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_coach_provider_map UNIQUE (provider, provider_coach_id),
    CONSTRAINT fk_coach_provider_map_coach
        FOREIGN KEY (coach_id) REFERENCES public.coaches(id)
        ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- 4) staging coaches (jen pokud není)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS staging.stg_provider_coaches (
    id                      BIGSERIAL PRIMARY KEY,
    provider                TEXT NOT NULL,
    sport_code              TEXT NOT NULL,
    external_coach_id       TEXT NOT NULL,
    coach_name              TEXT,
    first_name              TEXT,
    last_name               TEXT,
    nationality             TEXT,
    team_external_id        TEXT,
    team_name               TEXT,
    league_external_id      TEXT,
    season                  TEXT,
    source_payload_hash     TEXT,
    created_at              TIMESTAMPTZ DEFAULT NOW()
);

-- ---------------------------------------------------------
-- 5) indexy
-- ---------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_coaches_sport_id
    ON public.coaches (sport_id);

CREATE INDEX IF NOT EXISTS idx_team_coaches_current
    ON public.team_coaches (team_id, is_current);

CREATE INDEX IF NOT EXISTS idx_stg_provider_coaches
    ON staging.stg_provider_coaches (provider, external_coach_id);

COMMIT;