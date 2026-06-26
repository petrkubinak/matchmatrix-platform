/*
MATCHMATRIX 104_Y - CREATE PLAYER FORM TABLE V1

Co tabulka dělá:
- ukládá agregovanou formu hráče

K čemu slouží:
- AI
- fantasy
- player trends
- momentum
- recommendation engine

Web/app využití:
- FORM
- HOT/COLD streak
- player rating
- fantasy value
*/

CREATE TABLE IF NOT EXISTS public.player_form (
    id BIGSERIAL PRIMARY KEY,

    player_id BIGINT NOT NULL,
    sport_id INTEGER NOT NULL,

    matches_last_5 INTEGER,
    matches_last_10 INTEGER,

    avg_rating_last_5 NUMERIC,
    avg_rating_last_10 NUMERIC,

    goals_last_5 INTEGER,
    goals_last_10 INTEGER,

    assists_last_5 INTEGER,
    assists_last_10 INTEGER,

    shots_last_5 INTEGER,
    shots_last_10 INTEGER,

    key_passes_last_5 INTEGER,
    key_passes_last_10 INTEGER,

    minutes_last_5 INTEGER,
    minutes_last_10 INTEGER,

    yellow_cards_last_5 INTEGER,
    red_cards_last_5 INTEGER,

    form_score NUMERIC,
    momentum_score NUMERIC,

    last_match_id BIGINT,
    last_match_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_player_form_player
ON public.player_form(player_id);

CREATE INDEX IF NOT EXISTS ix_player_form_sport
ON public.player_form(sport_id);

CREATE INDEX IF NOT EXISTS ix_player_form_form_score
ON public.player_form(form_score DESC);

CREATE INDEX IF NOT EXISTS ix_player_form_momentum
ON public.player_form(momentum_score DESC);