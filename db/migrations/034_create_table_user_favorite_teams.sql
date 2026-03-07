-- =========================================================
-- Soubor: 034_create_table_user_favorite_teams.sql
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.user_favorite_teams (
    id              BIGSERIAL PRIMARY KEY,

    user_id         BIGINT NOT NULL,
    team_id         INTEGER NOT NULL,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_favorite_teams_user
        FOREIGN KEY (user_id)
        REFERENCES public.users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_favorite_teams_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_user_favorite_teams_user_team
    ON public.user_favorite_teams (user_id, team_id);

CREATE INDEX IF NOT EXISTS ix_user_favorite_teams_user
    ON public.user_favorite_teams (user_id);

COMMIT;