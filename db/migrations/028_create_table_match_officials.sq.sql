-- =========================================================
-- Soubor: 028_create_table_match_officials.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: rozhodčí a další oficiální osoby zápasu
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.match_officials (
    id                  BIGSERIAL PRIMARY KEY,

    match_id            BIGINT NOT NULL,
    official_name       TEXT NOT NULL,
    official_role       TEXT NOT NULL,   -- referee / assistant_referee / fourth_official / var
    nationality         TEXT NULL,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_match_officials_match
        FOREIGN KEY (match_id)
        REFERENCES public.matches(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_match_officials_match
    ON public.match_officials (match_id);

CREATE INDEX IF NOT EXISTS ix_match_officials_role
    ON public.match_officials (official_role);

COMMIT;