-- =========================================================
-- Soubor: 025_create_table_coaches.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.coaches
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.coaches (
    id                  BIGSERIAL PRIMARY KEY,

    name                TEXT NOT NULL,
    first_name          TEXT NULL,
    last_name           TEXT NULL,
    short_name          TEXT NULL,

    birth_date          DATE NULL,
    nationality         TEXT NULL,

    is_active           BOOLEAN NOT NULL DEFAULT TRUE,

    ext_source          TEXT NULL,
    ext_coach_id        TEXT NULL,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_coaches_ext_source_id
    ON public.coaches (ext_source, ext_coach_id)
    WHERE ext_source IS NOT NULL
      AND ext_coach_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_coaches_name
    ON public.coaches (name);

CREATE INDEX IF NOT EXISTS ix_coaches_is_active
    ON public.coaches (is_active);

COMMIT;