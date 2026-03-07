-- =========================================================
-- Soubor: 016_create_table_player_translations.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.player_translations
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.player_translations (
    id                  BIGSERIAL PRIMARY KEY,

    player_id           BIGINT NOT NULL,
    language_code       TEXT NOT NULL,

    translated_name     TEXT NULL,
    translated_slug     TEXT NULL,
    short_name          TEXT NULL,
    description         TEXT NULL,

    translation_source  TEXT NULL,   -- např. deepl / google / openai / manual
    is_auto_translated  BOOLEAN NOT NULL DEFAULT TRUE,
    is_reviewed         BOOLEAN NOT NULL DEFAULT FALSE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_player_translations_player
        FOREIGN KEY (player_id)
        REFERENCES public.players(id)
        ON DELETE CASCADE
);

-- jeden hráč může mít v jednom jazyce jen jeden překlad
CREATE UNIQUE INDEX IF NOT EXISTS ux_player_translations_player_language
    ON public.player_translations (player_id, language_code);

-- rychlé načítání překladů hráče
CREATE INDEX IF NOT EXISTS ix_player_translations_player_id
    ON public.player_translations (player_id);

-- rychlé filtrování podle jazyka
CREATE INDEX IF NOT EXISTS ix_player_translations_language_code
    ON public.player_translations (language_code);

-- pomocný index pro slug
CREATE INDEX IF NOT EXISTS ix_player_translations_slug
    ON public.player_translations (translated_slug);

COMMIT;