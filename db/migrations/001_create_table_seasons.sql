-- =========================================================
-- Soubor: 001_create_table_seasons.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.seasons
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.seasons (
    id              BIGSERIAL PRIMARY KEY,
    league_id       INTEGER NOT NULL,
    season_code     TEXT NOT NULL,
    season_label    TEXT NOT NULL,
    start_date      DATE NULL,
    end_date        DATE NULL,
    is_current      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_seasons_league
        FOREIGN KEY (league_id)
        REFERENCES public.leagues(id)
        ON DELETE CASCADE
);

-- jedna liga nesmí mít duplicitní season_code
CREATE UNIQUE INDEX IF NOT EXISTS ux_seasons_league_code
    ON public.seasons (league_id, season_code);

-- pro rychlé filtrování aktuálních sezon
CREATE INDEX IF NOT EXISTS ix_seasons_is_current
    ON public.seasons (is_current);

-- pro rychlé joiny na ligy
CREATE INDEX IF NOT EXISTS ix_seasons_league_id
    ON public.seasons (league_id);

COMMIT;