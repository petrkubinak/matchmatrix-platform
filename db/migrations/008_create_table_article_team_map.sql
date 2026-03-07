-- =========================================================
-- Soubor: 008_create_table_article_team_map.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.article_team_map
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.article_team_map (
    id              BIGSERIAL PRIMARY KEY,

    article_id      BIGINT NOT NULL,
    team_id         INTEGER NOT NULL,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_article_team_map_article
        FOREIGN KEY (article_id)
        REFERENCES public.articles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_article_team_map_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE CASCADE
);

-- jeden článek nemá být na stejný tým navázán vícekrát
CREATE UNIQUE INDEX IF NOT EXISTS ux_article_team_map_article_team
    ON public.article_team_map (article_id, team_id);

-- rychlé načítání článků týmu
CREATE INDEX IF NOT EXISTS ix_article_team_map_team_id
    ON public.article_team_map (team_id);

-- rychlé načítání týmů článku
CREATE INDEX IF NOT EXISTS ix_article_team_map_article_id
    ON public.article_team_map (article_id);

COMMIT;