-- =========================================================
-- Soubor: 013_create_table_article_translations.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.article_translations
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.article_translations (
    id                  BIGSERIAL PRIMARY KEY,

    article_id          BIGINT NOT NULL,
    language_code       TEXT NOT NULL,

    translated_title    TEXT NULL,
    translated_summary  TEXT NULL,
    translated_text     TEXT NULL,
    translated_slug     TEXT NULL,

    translation_source  TEXT NULL,   -- např. deepl / google / openai / manual
    is_auto_translated  BOOLEAN NOT NULL DEFAULT TRUE,
    is_reviewed         BOOLEAN NOT NULL DEFAULT FALSE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_article_translations_article
        FOREIGN KEY (article_id)
        REFERENCES public.articles(id)
        ON DELETE CASCADE
);

-- jeden článek může mít jen jednu překladovou verzi pro jeden jazyk
CREATE UNIQUE INDEX IF NOT EXISTS ux_article_translations_article_language
    ON public.article_translations (article_id, language_code);

-- rychlé filtrování podle jazyka
CREATE INDEX IF NOT EXISTS ix_article_translations_language_code
    ON public.article_translations (language_code);

-- rychlé načítání překladů článku
CREATE INDEX IF NOT EXISTS ix_article_translations_article_id
    ON public.article_translations (article_id);

-- pomocný index pro překladový slug
CREATE INDEX IF NOT EXISTS ix_article_translations_slug
    ON public.article_translations (translated_slug);

COMMIT;