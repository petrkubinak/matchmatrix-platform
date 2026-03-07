-- =========================================================
-- Soubor: 038_create_table_subscriptions.sql
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.subscriptions (
    id                  BIGSERIAL PRIMARY KEY,

    user_id             BIGINT NOT NULL,
    plan_id             BIGINT NOT NULL,

    status              TEXT NOT NULL DEFAULT 'active', -- active / canceled / expired / trial

    start_date          DATE NOT NULL,
    end_date            DATE NULL,

    payment_provider    TEXT NULL, -- stripe / paypal / apple / google
    external_payment_id TEXT NULL,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_subscriptions_user
        FOREIGN KEY (user_id)
        REFERENCES public.users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_subscriptions_plan
        FOREIGN KEY (plan_id)
        REFERENCES public.subscription_plans(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS ix_subscriptions_user
    ON public.subscriptions (user_id);

CREATE INDEX IF NOT EXISTS ix_subscriptions_status
    ON public.subscriptions (status);

COMMIT;