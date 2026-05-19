-- 901_provider_accounts_overview.sql

SELECT
    provider,
    account_name,
    plan_code,
    is_active,
    daily_limit_total,
    daily_limit_per_sport,
    safety_reserve_pct,
    api_base_url,
    created_at
FROM ops.provider_accounts
ORDER BY
    provider,
    account_name;