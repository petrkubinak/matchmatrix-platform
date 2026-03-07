-- =========================================================
-- Soubor: 020_create_table_stadiums.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.stadiums
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.stadiums (
    id              BIGSERIAL PRIMARY KEY,

    name            TEXT NOT NULL,
    city            TEXT NULL,
    country_code    TEXT NULL,

    capacity        INTEGER NULL,
    opened_year     INTEGER NULL,

    latitude        NUMERIC(10,7) NULL,
    longitude       NUMERIC(10,7) NULL,

    surface_type    TEXT NULL,      -- grass / artificial / hybrid

    is_active       BOOLEAN NOT NULL DEFAULT TRUE,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- rychlé filtrování podle země
CREATE INDEX IF NOT EXISTS ix_stadiums_country
    ON public.stadiums (country_code);

-- rychlé filtrování podle města
CREATE INDEX IF NOT EXISTS ix_stadiums_city
    ON public.stadiums (city);

-- filtrování aktivních stadionů
CREATE INDEX IF NOT EXISTS ix_stadiums_is_active
    ON public.stadiums (is_active);

COMMIT;