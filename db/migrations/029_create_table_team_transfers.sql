-- =========================================================
-- Soubor: 029_create_table_team_transfers.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: přestupy hráčů mezi týmy
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.team_transfers (
    id                  BIGSERIAL PRIMARY KEY,

    player_id           BIGINT NOT NULL,
    from_team_id        INTEGER NULL,
    to_team_id          INTEGER NULL,

    transfer_date       DATE NULL,
    transfer_type       TEXT NULL,       -- permanent / loan / free / return_loan
    transfer_fee        NUMERIC(14,2) NULL,
    currency_code       TEXT NULL,

    notes               TEXT NULL,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_team_transfers_player
        FOREIGN KEY (player_id)
        REFERENCES public.players(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_team_transfers_from_team
        FOREIGN KEY (from_team_id)
        REFERENCES public.teams(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_team_transfers_to_team
        FOREIGN KEY (to_team_id)
        REFERENCES public.teams(id)
        ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS ix_team_transfers_player
    ON public.team_transfers (player_id);

CREATE INDEX IF NOT EXISTS ix_team_transfers_from_team
    ON public.team_transfers (from_team_id);

CREATE INDEX IF NOT EXISTS ix_team_transfers_to_team
    ON public.team_transfers (to_team_id);

CREATE INDEX IF NOT EXISTS ix_team_transfers_date
    ON public.team_transfers (transfer_date);

COMMIT;