-- =========================================================
-- Soubor: 006_create_table_content_sources.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.content_sources
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.content_sources (
    id              BIGSERIAL PRIMARY KEY,

    name            TEXT NOT NULL,
    source_type     TEXT NOT NULL,
    base_url        TEXT NULL,
    rss_url         TEXT NULL,

    language_code   TEXT NULL,
    country_code    TEXT NULL,

    is_official     BOOLEAN NOT NULL DEFAULT FALSE,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,

    notes           TEXT NULL,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- rychlé filtrování aktivních zdrojů
CREATE INDEX IF NOT EXISTS ix_content_sources_is_active
    ON public.content_sources (is_active);

-- filtrování podle typu zdroje
CREATE INDEX IF NOT EXISTS ix_content_sources_source_type
    ON public.content_sources (source_type);

-- filtrování podle jazyka
CREATE INDEX IF NOT EXISTS ix_content_sources_language
    ON public.content_sources (language_code);

COMMIT;