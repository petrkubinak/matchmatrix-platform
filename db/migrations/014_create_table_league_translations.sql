-- =========================================================
-- Soubor: 014_create_table_league_translations.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.league_translations
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.league_translations (
    id                  BIGSERIAL PRIMARY KEY,

    league_id           INTEGER NOT NULL,
    language_code       TEXT NOT NULL,

    translated_name     TEXT NOT NULL,
    translated_slug     TEXT NULL,
    short_name          TEXT NULL,
    description         TEXT NULL,

    translation_source  TEXT NULL,   -- např. deepl / google / openai / manual
    is_auto_translated  BOOLEAN NOT NULL DEFAULT TRUE,
    is_reviewed         BOOLEAN NOT NULL DEFAULT FALSE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_league_translations_league
        FOREIGN KEY (league_id)
        REFERENCES public.leagues(id)
        ON DELETE CASCADE
);

-- jedna liga může mít v jednom jazyce jen jeden překlad
CREATE UNIQUE INDEX IF NOT EXISTS ux_league_translations_league_language
    ON public.league_translations (league_id, language_code);

-- rychlé načítání překladů ligy
CREATE INDEX IF NOT EXISTS ix_league_translations_league_id
    ON public.league_translations (league_id);

-- rychlé filtrování podle jazyka
CREATE INDEX IF NOT EXISTS ix_league_translations_language_code
    ON public.league_translations (language_code);

-- pomocný index pro slug
CREATE INDEX IF NOT EXISTS ix_league_translations_slug
    ON public.league_translations (translated_slug);

COMMIT;