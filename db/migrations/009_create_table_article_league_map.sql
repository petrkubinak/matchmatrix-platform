-- =========================================================
-- Soubor: 009_create_table_article_league_map.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.article_league_map
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.article_league_map (
    id              BIGSERIAL PRIMARY KEY,

    article_id      BIGINT NOT NULL,
    league_id       INTEGER NOT NULL,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_article_league_map_article
        FOREIGN KEY (article_id)
        REFERENCES public.articles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_article_league_map_league
        FOREIGN KEY (league_id)
        REFERENCES public.leagues(id)
        ON DELETE CASCADE
);

-- jeden článek nemá být na stejnou ligu navázán vícekrát
CREATE UNIQUE INDEX IF NOT EXISTS ux_article_league_map_article_league
    ON public.article_league_map (article_id, league_id);

-- rychlé načítání článků ligy
CREATE INDEX IF NOT EXISTS ix_article_league_map_league_id
    ON public.article_league_map (league_id);

-- rychlé načítání lig článku
CREATE INDEX IF NOT EXISTS ix_article_league_map_article_id
    ON public.article_league_map (article_id);

COMMIT;