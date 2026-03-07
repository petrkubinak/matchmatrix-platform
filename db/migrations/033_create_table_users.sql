-- =========================================================
-- Soubor: 033_create_table_users.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: základní uživatelská tabulka
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.users (
    id                  BIGSERIAL PRIMARY KEY,

    email               TEXT NOT NULL,
    password_hash       TEXT NULL,

    username            TEXT NULL,
    display_name        TEXT NULL,

    language_code       TEXT NULL,
    country_code        TEXT NULL,
    timezone            TEXT NULL,

    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified         BOOLEAN NOT NULL DEFAULT FALSE,
    is_admin            BOOLEAN NOT NULL DEFAULT FALSE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at       TIMESTAMPTZ NULL
);

-- email musí být unikátní
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_email
    ON public.users (email);

CREATE UNIQUE INDEX IF NOT EXISTS ux_users_username
    ON public.users (username)
    WHERE username IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_users_is_active
    ON public.users (is_active);

CREATE INDEX IF NOT EXISTS ix_users_language
    ON public.users (language_code);

COMMIT;