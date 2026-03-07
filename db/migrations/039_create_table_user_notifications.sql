-- =========================================================
-- Soubor: 039_create_table_user_notifications.sql
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.user_notifications (
    id                  BIGSERIAL PRIMARY KEY,

    user_id             BIGINT NOT NULL,

    notification_type   TEXT NOT NULL, -- match_start / goal / odds_change / injury / news
    entity_type         TEXT NULL,     -- match / team / player / league
    entity_id           BIGINT NULL,

    title               TEXT NOT NULL,
    message             TEXT NOT NULL,

    is_read             BOOLEAN NOT NULL DEFAULT FALSE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_notifications_user
        FOREIGN KEY (user_id)
        REFERENCES public.users(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_user_notifications_user
    ON public.user_notifications (user_id);

CREATE INDEX IF NOT EXISTS ix_user_notifications_read
    ON public.user_notifications (is_read);

CREATE INDEX IF NOT EXISTS ix_user_notifications_type
    ON public.user_notifications (notification_type);

COMMIT;