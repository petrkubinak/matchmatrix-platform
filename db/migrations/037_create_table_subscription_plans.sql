-- =========================================================
-- Soubor: 037_create_table_subscription_plans.sql
-- Uložit do: C:\MatchMatrix-platform\db\migrations
-- Účel: definice plánů předplatného
-- =========================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.subscription_plans (
    id                  BIGSERIAL PRIMARY KEY,

    plan_code           TEXT NOT NULL,
    plan_name           TEXT NOT NULL,

    price_monthly       NUMERIC(10,2) NULL,
    price_yearly        NUMERIC(10,2) NULL,
    currency_code       TEXT NOT NULL DEFAULT 'EUR',

    max_favorite_teams  INTEGER NULL,
    max_favorite_leagues INTEGER NULL,
    max_favorite_players INTEGER NULL,

    has_advanced_stats  BOOLEAN NOT NULL DEFAULT FALSE,
    has_ai_predictions  BOOLEAN NOT NULL DEFAULT FALSE,
    has_odds_comparison BOOLEAN NOT NULL DEFAULT FALSE,

    is_active           BOOLEAN NOT NULL DEFAULT TRUE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_subscription_plans_code
    ON public.subscription_plans (plan_code);

CREATE INDEX IF NOT EXISTS ix_subscription_plans_active
    ON public.subscription_plans (is_active);

COMMIT;