-- =========================================================
-- Soubor: 023_create_table_player_match_statistics.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.player_match_statistics
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.player_match_statistics (
    id                      BIGSERIAL PRIMARY KEY,

    match_id                BIGINT NOT NULL,
    team_id                 INTEGER NOT NULL,
    player_id               BIGINT NOT NULL,

    minutes_played          INTEGER NULL,

    goals                   INTEGER NOT NULL DEFAULT 0,
    assists                 INTEGER NOT NULL DEFAULT 0,
    shots_total             INTEGER NOT NULL DEFAULT 0,
    shots_on_target         INTEGER NOT NULL DEFAULT 0,

    passes_total            INTEGER NOT NULL DEFAULT 0,
    passes_accurate         INTEGER NOT NULL DEFAULT 0,
    key_passes              INTEGER NOT NULL DEFAULT 0,

    dribbles_attempted      INTEGER NOT NULL DEFAULT 0,
    dribbles_successful     INTEGER NOT NULL DEFAULT 0,

    tackles                 INTEGER NOT NULL DEFAULT 0,
    interceptions           INTEGER NOT NULL DEFAULT 0,
    clearances              INTEGER NOT NULL DEFAULT 0,
    blocks                  INTEGER NOT NULL DEFAULT 0,

    fouls_committed         INTEGER NOT NULL DEFAULT 0,
    fouls_drawn             INTEGER NOT NULL DEFAULT 0,

    yellow_cards            INTEGER NOT NULL DEFAULT 0,
    red_cards               INTEGER NOT NULL DEFAULT 0,

    offsides                INTEGER NOT NULL DEFAULT 0,
    saves                   INTEGER NOT NULL DEFAULT 0,

    rating                  NUMERIC(4,2) NULL,
    xg                      NUMERIC(8,4) NULL,
    xa                      NUMERIC(8,4) NULL,

    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_player_match_statistics_match
        FOREIGN KEY (match_id)
        REFERENCES public.matches(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_player_match_statistics_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_player_match_statistics_player
        FOREIGN KEY (player_id)
        REFERENCES public.players(id)
        ON DELETE CASCADE
);

-- jeden hráč má pro jeden zápas jen jeden statistický řádek
CREATE UNIQUE INDEX IF NOT EXISTS ux_player_match_statistics_match_player
    ON public.player_match_statistics (match_id, player_id);

-- rychlé načítání statistik zápasu
CREATE INDEX IF NOT EXISTS ix_player_match_statistics_match
    ON public.player_match_statistics (match_id);

-- rychlé načítání statistik hráče
CREATE INDEX IF NOT EXISTS ix_player_match_statistics_player
    ON public.player_match_statistics (player_id);

-- rychlé filtrování podle týmu
CREATE INDEX IF NOT EXISTS ix_player_match_statistics_team
    ON public.player_match_statistics (team_id);

-- pomocný index na rating
CREATE INDEX IF NOT EXISTS ix_player_match_statistics_rating
    ON public.player_match_statistics (rating);

COMMIT;