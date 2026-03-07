-- =========================================================
-- Soubor: 021_create_table_team_stadiums.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: propojení týmů a stadionů
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.team_stadiums (
    id              BIGSERIAL PRIMARY KEY,

    team_id         INTEGER NOT NULL,
    stadium_id      BIGINT NOT NULL,

    is_primary      BOOLEAN NOT NULL DEFAULT TRUE,

    start_date      DATE NULL,
    end_date        DATE NULL,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_team_stadiums_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_team_stadiums_stadium
        FOREIGN KEY (stadium_id)
        REFERENCES public.stadiums(id)
        ON DELETE CASCADE
);

-- jeden stadion může být primární jen jednou pro tým
CREATE INDEX IF NOT EXISTS ix_team_stadiums_team
    ON public.team_stadiums (team_id);

CREATE INDEX IF NOT EXISTS ix_team_stadiums_stadium
    ON public.team_stadiums (stadium_id);

CREATE INDEX IF NOT EXISTS ix_team_stadiums_primary
    ON public.team_stadiums (is_primary);

COMMIT;