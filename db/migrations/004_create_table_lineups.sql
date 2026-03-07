-- =========================================================
-- Soubor: 004_create_table_lineups.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.lineups
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.lineups (
    id              BIGSERIAL PRIMARY KEY,
    match_id        BIGINT NOT NULL,
    team_id         INTEGER NOT NULL,
    player_id       BIGINT NOT NULL,

    is_starting     BOOLEAN NOT NULL DEFAULT FALSE,
    formation_slot  INTEGER NULL,
    position_code   TEXT NULL,
    position_label  TEXT NULL,

    shirt_number    INTEGER NULL,
    is_captain      BOOLEAN NOT NULL DEFAULT FALSE,

    minute_in       INTEGER NULL,
    minute_out      INTEGER NULL,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_lineups_match
        FOREIGN KEY (match_id)
        REFERENCES public.matches(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_lineups_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_lineups_player
        FOREIGN KEY (player_id)
        REFERENCES public.players(id)
        ON DELETE CASCADE
);

-- aby jeden hráč nebyl dvakrát v sestavě stejného zápasu
CREATE UNIQUE INDEX IF NOT EXISTS ux_lineups_match_player
    ON public.lineups (match_id, player_id);

-- rychlé načítání sestavy zápasu
CREATE INDEX IF NOT EXISTS ix_lineups_match
    ON public.lineups (match_id);

-- rychlé filtrování podle týmu
CREATE INDEX IF NOT EXISTS ix_lineups_team
    ON public.lineups (team_id);

-- rychlé filtrování podle hráče
CREATE INDEX IF NOT EXISTS ix_lineups_player
    ON public.lineups (player_id);

-- základní sestava
CREATE INDEX IF NOT EXISTS ix_lineups_is_starting
    ON public.lineups (is_starting);

COMMIT;