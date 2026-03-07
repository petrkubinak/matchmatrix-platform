-- =========================================================
-- Soubor: 005_create_table_injuries.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.injuries
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.injuries (
    id                      BIGSERIAL PRIMARY KEY,

    player_id               BIGINT NOT NULL,
    team_id                 INTEGER NULL,

    injury_type             TEXT NULL,
    injury_area             TEXT NULL,
    status                  TEXT NULL,

    start_date              DATE NULL,
    expected_return_date    DATE NULL,
    end_date                DATE NULL,

    source_name             TEXT NULL,
    source_url              TEXT NULL,

    notes                   TEXT NULL,

    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_injuries_player
        FOREIGN KEY (player_id)
        REFERENCES public.players(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_injuries_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE SET NULL
);

-- rychlé vyhledávání podle hráče
CREATE INDEX IF NOT EXISTS ix_injuries_player_id
    ON public.injuries (player_id);

-- rychlé vyhledávání podle týmu
CREATE INDEX IF NOT EXISTS ix_injuries_team_id
    ON public.injuries (team_id);

-- aktivní zranění
CREATE INDEX IF NOT EXISTS ix_injuries_status
    ON public.injuries (status);

-- rychlé filtrování podle data
CREATE INDEX IF NOT EXISTS ix_injuries_start_date
    ON public.injuries (start_date);

COMMIT;