CREATE TABLE IF NOT EXISTS ops.provider_accounts (
    id BIGSERIAL PRIMARY KEY,
    provider TEXT NOT NULL,
    account_name TEXT NOT NULL,
    plan_code TEXT NOT NULL, -- free / pro / enterprise
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    daily_limit_total INT,
    daily_limit_per_sport INT,
    safety_reserve_pct NUMERIC(5,2) NOT NULL DEFAULT 10.00,

    api_base_url TEXT,
    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_provider_accounts_plan_code
        CHECK (plan_code IN ('free', 'pro', 'enterprise'))
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_provider_accounts_provider_account_name
    ON ops.provider_accounts(provider, account_name);