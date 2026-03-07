-- =========================================================
-- Soubor: 015_create_table_team_translations.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.team_translations
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.team_translations (
    id                  BIGSERIAL PRIMARY KEY,

    team_id             INTEGER NOT NULL,
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

    CONSTRAINT fk_team_translations_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE CASCADE
);

-- jeden tým může mít v jednom jazyce jen jeden překlad
CREATE UNIQUE INDEX IF NOT EXISTS ux_team_translations_team_language
    ON public.team_translations (team_id, language_code);

-- rychlé načítání překladů týmu
CREATE INDEX IF NOT EXISTS ix_team_translations_team_id
    ON public.team_translations (team_id);

-- rychlé filtrování podle jazyka
CREATE INDEX IF NOT EXISTS ix_team_translations_language_code
    ON public.team_translations (language_code);

-- pomocný index pro slug
CREATE INDEX IF NOT EXISTS ix_team_translations_slug
    ON public.team_translations (translated_slug);

COMMIT;