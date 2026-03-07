-- =========================================================
-- Soubor: 027_create_table_player_team_history.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: historie působení hráče v týmech
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.player_team_history (
    id                  BIGSERIAL PRIMARY KEY,

    player_id           BIGINT NOT NULL,
    team_id             INTEGER NOT NULL,
    season_id           BIGINT NULL,

    shirt_number        INTEGER NULL,
    position            TEXT NULL,

    start_date          DATE NULL,
    end_date            DATE NULL,
    is_current          BOOLEAN NOT NULL DEFAULT TRUE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_player_team_history_player
        FOREIGN KEY (player_id)
        REFERENCES public.players(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_player_team_history_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_player_team_history_season
        FOREIGN KEY (season_id)
        REFERENCES public.seasons(id)
        ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS ix_player_team_history_player
    ON public.player_team_history (player_id);

CREATE INDEX IF NOT EXISTS ix_player_team_history_team
    ON public.player_team_history (team_id);

CREATE INDEX IF NOT EXISTS ix_player_team_history_season
    ON public.player_team_history (season_id);

CREATE INDEX IF NOT EXISTS ix_player_team_history_is_current
    ON public.player_team_history (is_current);

COMMIT;