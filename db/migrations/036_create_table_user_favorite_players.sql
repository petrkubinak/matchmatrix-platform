-- =========================================================
-- Soubor: 036_create_table_user_favorite_players.sql
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.user_favorite_players (
    id              BIGSERIAL PRIMARY KEY,

    user_id         BIGINT NOT NULL,
    player_id       BIGINT NOT NULL,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_favorite_players_user
        FOREIGN KEY (user_id)
        REFERENCES public.users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_favorite_players_player
        FOREIGN KEY (player_id)
        REFERENCES public.players(id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_user_favorite_players_user_player
    ON public.user_favorite_players (user_id, player_id);

CREATE INDEX IF NOT EXISTS ix_user_favorite_players_user
    ON public.user_favorite_players (user_id);

COMMIT;