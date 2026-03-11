INSERT INTO ops.provider_accounts (
    provider,
    account_name,
    plan_code,
    is_active,
    daily_limit_total,
    daily_limit_per_sport,
    safety_reserve_pct,
    api_base_url,
    notes
)
VALUES (
    'api_sport',
    'default_free',
    'free',
    TRUE,
    NULL,
    100,
    10.00,
    'SET_REAL_API_BASE_URL_HERE',
    'Free account: 100 requests per sport per day'
)
ON CONFLICT DO NOTHING;