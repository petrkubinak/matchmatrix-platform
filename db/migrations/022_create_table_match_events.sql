-- =========================================================
-- Soubor: 022_create_table_match_events.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.match_events
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.match_events (
    id                  BIGSERIAL PRIMARY KEY,

    match_id            BIGINT NOT NULL,
    team_id             INTEGER NULL,
    player_id           BIGINT NULL,
    related_player_id   BIGINT NULL, -- např. hráč který asistoval nebo byl vystřídán

    event_type          TEXT NOT NULL,  -- goal / assist / yellow_card / red_card / substitution / penalty / var
    event_minute        INTEGER NOT NULL,
    event_extra_minute  INTEGER NULL,

    event_detail        TEXT NULL,      -- např. header / penalty / own_goal / var_review

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_match_events_match
        FOREIGN KEY (match_id)
        REFERENCES public.matches(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_match_events_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_match_events_player
        FOREIGN KEY (player_id)
        REFERENCES public.players(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_match_events_related_player
        FOREIGN KEY (related_player_id)
        REFERENCES public.players(id)
        ON DELETE SET NULL,

    CONSTRAINT ck_match_events_type
        CHECK (event_type IN (
            'goal',
            'assist',
            'yellow_card',
            'red_card',
            'substitution',
            'penalty',
            'var',
            'own_goal',
            'missed_penalty'
        ))
);

-- rychlé načítání eventů zápasu
CREATE INDEX IF NOT EXISTS ix_match_events_match
    ON public.match_events (match_id);

-- filtrování podle hráče
CREATE INDEX IF NOT EXISTS ix_match_events_player
    ON public.match_events (player_id);

-- filtrování podle týmu
CREATE INDEX IF NOT EXISTS ix_match_events_team
    ON public.match_events (team_id);

-- filtrování podle typu eventu
CREATE INDEX IF NOT EXISTS ix_match_events_type
    ON public.match_events (event_type);

-- rychlé řazení podle času
CREATE INDEX IF NOT EXISTS ix_match_events_minute
    ON public.match_events (event_minute);

COMMIT;