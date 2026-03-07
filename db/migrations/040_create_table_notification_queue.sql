-- =========================================================
-- Soubor: 040_create_table_notification_queue.sql
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.notification_queue (
    id                  BIGSERIAL PRIMARY KEY,

    notification_type   TEXT NOT NULL,
    entity_type         TEXT NULL,
    entity_id           BIGINT NULL,

    payload             JSONB NULL,

    status              TEXT NOT NULL DEFAULT 'pending', -- pending / processing / sent / failed
    attempt_count       INTEGER NOT NULL DEFAULT 0,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at        TIMESTAMPTZ NULL
);

CREATE INDEX IF NOT EXISTS ix_notification_queue_status
    ON public.notification_queue (status);

CREATE INDEX IF NOT EXISTS ix_notification_queue_entity
    ON public.notification_queue (entity_type, entity_id);

COMMIT;