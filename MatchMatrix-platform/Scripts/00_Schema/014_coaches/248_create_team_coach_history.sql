-- ============================================================
-- MatchMatrix
-- 130_create_team_coach_history.sql
-- ------------------------------------------------------------
-- Účel:
--   Historie trenérů u týmů.
--
-- Kam uložit:
--   C:\MatchMatrix-platform\db\migrations\130_create_team_coach_history.sql
-- ============================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.team_coach_history (
    id bigserial PRIMARY KEY,

    team_id bigint NOT NULL,
    coach_id bigint NOT NULL,

    sport_id int4 NULL,
    league_id int4 NULL,
    season varchar(20) NULL,

    role_code varchar(50) NULL,          -- head_coach, assistant, interim, caretaker...
    role_name varchar(100) NULL,

    start_date date NULL,
    end_date date NULL,
    is_current boolean NOT NULL DEFAULT false,

    source_type varchar(50) NOT NULL DEFAULT 'provider',   -- provider / manual / derived
    source_note text NULL,

    provider varchar(100) NULL,
    provider_coach_id varchar(100) NULL,
    provider_team_id varchar(100) NULL,
    provider_league_id varchar(100) NULL,

    confidence_score numeric(5,2) NULL,  -- např. 0.00 - 100.00

    raw_payload_id bigint NULL,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------
-- FK
-- ------------------------------------------------------------

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_team_coach_history_team'
    ) THEN
        ALTER TABLE public.team_coach_history
        ADD CONSTRAINT fk_team_coach_history_team
        FOREIGN KEY (team_id) REFERENCES public.teams(id);
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_team_coach_history_coach'
    ) THEN
        ALTER TABLE public.team_coach_history
        ADD CONSTRAINT fk_team_coach_history_coach
        FOREIGN KEY (coach_id) REFERENCES public.coaches(id);
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_team_coach_history_sport'
    ) THEN
        ALTER TABLE public.team_coach_history
        ADD CONSTRAINT fk_team_coach_history_sport
        FOREIGN KEY (sport_id) REFERENCES public.sports(id);
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_team_coach_history_league'
    ) THEN
        ALTER TABLE public.team_coach_history
        ADD CONSTRAINT fk_team_coach_history_league
        FOREIGN KEY (league_id) REFERENCES public.leagues(id);
    END IF;
END$$;

-- ------------------------------------------------------------
-- Unikátní business klíč
-- ------------------------------------------------------------

CREATE UNIQUE INDEX IF NOT EXISTS ux_team_coach_history_business
ON public.team_coach_history (
    team_id,
    coach_id,
    COALESCE(start_date, DATE '1900-01-01'),
    COALESCE(end_date, DATE '2999-12-31'),
    COALESCE(role_code, ''),
    COALESCE(provider, ''),
    COALESCE(provider_team_id, ''),
    COALESCE(provider_coach_id, '')
);

-- ------------------------------------------------------------
-- Pomocné indexy
-- ------------------------------------------------------------

CREATE INDEX IF NOT EXISTS ix_team_coach_history_team_id
    ON public.team_coach_history (team_id);

CREATE INDEX IF NOT EXISTS ix_team_coach_history_coach_id
    ON public.team_coach_history (coach_id);

CREATE INDEX IF NOT EXISTS ix_team_coach_history_league_id
    ON public.team_coach_history (league_id);

CREATE INDEX IF NOT EXISTS ix_team_coach_history_season
    ON public.team_coach_history (season);

CREATE INDEX IF NOT EXISTS ix_team_coach_history_is_current
    ON public.team_coach_history (is_current);

CREATE INDEX IF NOT EXISTS ix_team_coach_history_provider_keys
    ON public.team_coach_history (provider, provider_team_id, provider_coach_id);

-- ------------------------------------------------------------
-- updated_at trigger
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.fn_set_updated_at_team_coach_history()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_updated_at_team_coach_history
ON public.team_coach_history;

CREATE TRIGGER trg_set_updated_at_team_coach_history
BEFORE UPDATE ON public.team_coach_history
FOR EACH ROW
EXECUTE FUNCTION public.fn_set_updated_at_team_coach_history();

COMMIT;