-- =========================================================
-- Soubor: 024_create_table_team_match_statistics.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: vytvoření tabulky public.team_match_statistics
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.team_match_statistics (
    id                      BIGSERIAL PRIMARY KEY,

    match_id                BIGINT NOT NULL,
    team_id                 INTEGER NOT NULL,

    possession_pct          NUMERIC(5,2) NULL,

    shots_total             INTEGER NOT NULL DEFAULT 0,
    shots_on_target         INTEGER NOT NULL DEFAULT 0,
    shots_off_target        INTEGER NOT NULL DEFAULT 0,
    shots_blocked           INTEGER NOT NULL DEFAULT 0,

    corners                 INTEGER NOT NULL DEFAULT 0,
    offsides                INTEGER NOT NULL DEFAULT 0,
    fouls                   INTEGER NOT NULL DEFAULT 0,

    yellow_cards            INTEGER NOT NULL DEFAULT 0,
    red_cards               INTEGER NOT NULL DEFAULT 0,

    passes_total            INTEGER NOT NULL DEFAULT 0,
    passes_accurate         INTEGER NOT NULL DEFAULT 0,
    pass_accuracy_pct       NUMERIC(5,2) NULL,

    tackles                 INTEGER NOT NULL DEFAULT 0,
    interceptions           INTEGER NOT NULL DEFAULT 0,
    clearances              INTEGER NOT NULL DEFAULT 0,

    saves                   INTEGER NOT NULL DEFAULT 0,

    xg                      NUMERIC(8,4) NULL,
    xa                      NUMERIC(8,4) NULL,

    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_team_match_statistics_match
        FOREIGN KEY (match_id)
        REFERENCES public.matches(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_team_match_statistics_team
        FOREIGN KEY (team_id)
        REFERENCES public.teams(id)
        ON DELETE CASCADE
);

-- jeden tým má pro jeden zápas jen jeden statistický řádek
CREATE UNIQUE INDEX IF NOT EXISTS ux_team_match_statistics_match_team
    ON public.team_match_statistics (match_id, team_id);

CREATE INDEX IF NOT EXISTS ix_team_match_statistics_match
    ON public.team_match_statistics (match_id);

CREATE INDEX IF NOT EXISTS ix_team_match_statistics_team
    ON public.team_match_statistics (team_id);

COMMIT;