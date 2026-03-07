-- =========================================================
-- Soubor: 026_create_table_team_coaches.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: propojení trenérů a týmů v čase
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.team_coaches (
    id                  BIGSERIAL PRIMARY KEY,

    team_id             INTEGER NOT NULL,
    coach_id            BIGINT NOT NULL,

    role_code           TEXT NOT NULL DEFAULT 'head_coach', -- head_coach / assistant / caretaker
    start_date          DATE NULL,
    end_date            DATE NULL,
    is_current          BOOLEAN NOT NULL DEFAULT TRUE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_team_coaches_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_team_coaches_coach
        FOREIGN KEY (coach_id)
        REFERENCES public.coaches(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_team_coaches_team
    ON public.team_coaches (team_id);

CREATE INDEX IF NOT EXISTS ix_team_coaches_coach
    ON public.team_coaches (coach_id);

CREATE INDEX IF NOT EXISTS ix_team_coaches_is_current
    ON public.team_coaches (is_current);

COMMIT;