-- =========================================================
-- Soubor: 010_create_table_article_match_map.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.article_match_map
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.article_match_map (
    id              BIGSERIAL PRIMARY KEY,

    article_id      BIGINT NOT NULL,
    match_id        BIGINT NOT NULL,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_article_match_map_article
        FOREIGN KEY (article_id)
        REFERENCES public.articles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_article_match_map_match
        FOREIGN KEY (match_id)
        REFERENCES public.matches(id)
        ON DELETE CASCADE
);

-- jeden článek nemá být na stejný zápas navázán vícekrát
CREATE UNIQUE INDEX IF NOT EXISTS ux_article_match_map_article_match
    ON public.article_match_map (article_id, match_id);

-- rychlé načítání článků zápasu
CREATE INDEX IF NOT EXISTS ix_article_match_map_match_id
    ON public.article_match_map (match_id);

-- rychlé načítání zápasů článku
CREATE INDEX IF NOT EXISTS ix_article_match_map_article_id
    ON public.article_match_map (article_id);

COMMIT;