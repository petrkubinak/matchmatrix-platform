-- =========================================================
-- Soubor: 012_create_table_languages.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.languages
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.languages (
    id              BIGSERIAL PRIMARY KEY,
    language_code   TEXT NOT NULL,
    language_name   TEXT NOT NULL,
    native_name     TEXT NULL,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    is_default      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- každý jazykový kód jen jednou
CREATE UNIQUE INDEX IF NOT EXISTS ux_languages_code
    ON public.languages (language_code);

-- rychlé filtrování aktivních jazyků
CREATE INDEX IF NOT EXISTS ix_languages_is_active
    ON public.languages (is_active);

COMMIT;