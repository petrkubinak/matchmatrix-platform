-- =========================================================
-- Soubor: 031_create_table_competition_rounds.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: kola, fáze a round metadata soutěží
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.competition_rounds (
    id                  BIGSERIAL PRIMARY KEY,

    season_id           BIGINT NOT NULL,
    round_code          TEXT NOT NULL,
    round_label         TEXT NOT NULL,
    round_order         INTEGER NULL,

    stage_name          TEXT NULL,   -- regular season / playoffs / group stage / knockout
    is_current          BOOLEAN NOT NULL DEFAULT FALSE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_competition_rounds_season
        FOREIGN KEY (season_id)
        REFERENCES public.seasons(id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_competition_rounds_season_code
    ON public.competition_rounds (season_id, round_code);

CREATE INDEX IF NOT EXISTS ix_competition_rounds_season
    ON public.competition_rounds (season_id);

CREATE INDEX IF NOT EXISTS ix_competition_rounds_current
    ON public.competition_rounds (is_current);

COMMIT;