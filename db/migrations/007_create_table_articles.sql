-- =========================================================
-- Soubor: 007_create_table_articles.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.articles
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.articles (
    id                  BIGSERIAL PRIMARY KEY,

    content_source_id   BIGINT NOT NULL,

    title               TEXT NOT NULL,
    slug                TEXT NULL,
    summary             TEXT NULL,

    url                 TEXT NOT NULL,
    author_name         TEXT NULL,

    published_at        TIMESTAMPTZ NULL,
    language_code       TEXT NULL,
    content_type        TEXT NULL,

    raw_html_path       TEXT NULL,
    raw_text            TEXT NULL,
    ai_summary          TEXT NULL,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_articles_content_source
        FOREIGN KEY (content_source_id)
        REFERENCES public.content_sources(id)
        ON DELETE CASCADE
);

-- jeden článek podle URL pouze jednou
CREATE UNIQUE INDEX IF NOT EXISTS ux_articles_url
    ON public.articles (url);

-- rychlé řazení podle data publikace
CREATE INDEX IF NOT EXISTS ix_articles_published_at
    ON public.articles (published_at);

-- rychlé filtrování podle zdroje
CREATE INDEX IF NOT EXISTS ix_articles_content_source_id
    ON public.articles (content_source_id);

-- filtrování podle typu obsahu
CREATE INDEX IF NOT EXISTS ix_articles_content_type
    ON public.articles (content_type);

-- filtrování podle jazyka
CREATE INDEX IF NOT EXISTS ix_articles_language_code
    ON public.articles (language_code);

-- pomocný index pro slug
CREATE INDEX IF NOT EXISTS ix_articles_slug
    ON public.articles (slug);

COMMIT;