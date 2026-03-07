-- =========================================================
-- Soubor: 002_create_table_players.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.players
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.players (
    id               BIGSERIAL PRIMARY KEY,
    team_id          INTEGER NULL,
    name             TEXT NOT NULL,
    first_name       TEXT NULL,
    last_name        TEXT NULL,
    short_name       TEXT NULL,
    birth_date       DATE NULL,
    nationality      TEXT NULL,
    position         TEXT NULL,
    shirt_number     INTEGER NULL,
    height_cm        INTEGER NULL,
    weight_kg        INTEGER NULL,
    is_active        BOOLEAN NOT NULL DEFAULT TRUE,
    ext_source       TEXT NULL,
    ext_player_id    TEXT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_players_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE SET NULL
);

-- pokud budeš dočasně používat přímé provider napojení i bez mapovací tabulky
CREATE UNIQUE INDEX IF NOT EXISTS ux_players_ext_source_player_id
    ON public.players (ext_source, ext_player_id)
    WHERE ext_source IS NOT NULL
      AND ext_player_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_players_team_id
    ON public.players (team_id);

CREATE INDEX IF NOT EXISTS ix_players_name
    ON public.players (name);

CREATE INDEX IF NOT EXISTS ix_players_last_name
    ON public.players (last_name);

CREATE INDEX IF NOT EXISTS ix_players_is_active
    ON public.players (is_active);

COMMIT;