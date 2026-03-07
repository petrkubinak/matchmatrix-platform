-- =========================================================
-- Soubor: 035_create_table_user_favorite_leagues.sql
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.user_favorite_leagues (
    id              BIGSERIAL PRIMARY KEY,

    user_id         BIGINT NOT NULL,
    league_id       INTEGER NOT NULL,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_favorite_leagues_user
        FOREIGN KEY (user_id)
        REFERENCES public.users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_favorite_leagues_league
        FOREIGN KEY (league_id)
        REFERENCES public.leagues(id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_user_favorite_leagues_user_league
    ON public.user_favorite_leagues (user_id, league_id);

CREATE INDEX IF NOT EXISTS ix_user_favorite_leagues_user
    ON public.user_favorite_leagues (user_id);

COMMIT;