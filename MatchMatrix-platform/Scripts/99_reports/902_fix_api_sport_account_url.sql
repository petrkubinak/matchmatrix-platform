-- 902_fix_api_sport_account_url.sql
-- Oprava placeholder API base URL pro api_sport účet

UPDATE ops.provider_accounts
SET
    api_base_url = 'https://v1.basketball.api-sports.io',
    updated_at = now()
WHERE provider = 'api_sport'
  AND account_name = 'default_free';

SELECT
    provider,
    account_name,
    plan_code,
    is_active,
    daily_limit_total,
    daily_limit_per_sport,
    api_base_url,
    updated_at
FROM ops.provider_accounts
WHERE provider = 'api_sport';