INSERT INTO ops.provider_accounts (
    provider,
    account_name,
    plan_code,
    is_active,
    daily_limit_total,
    daily_limit_per_sport,
    safety_reserve_pct,
    notes
)
VALUES (
    'api_football',
    'default_free',
    'free',
    TRUE,
    NULL,
    100,
    10.00,
    'Default FREE účet pro football; po PRO změnit na 7500.'
)
ON CONFLICT DO NOTHING;

WITH provider_budget AS (
    SELECT
        CASE
            WHEN provider = 'api_football' THEN 'football'
            WHEN provider = 'api_hockey' THEN 'hockey'
            WHEN provider = 'api_sport' THEN 'basketball'
            WHEN provider = 'api_tennis' THEN 'tennis'
            WHEN provider = 'api_volleyball' THEN 'volleyball'
            WHEN provider = 'api_handball' THEN 'handball'
            WHEN provider = 'api_baseball' THEN 'baseball'
            WHEN provider = 'api_rugby' THEN 'rugby'
            WHEN provider = 'api_cricket' THEN 'cricket'
            WHEN provider = 'api_american_football' THEN 'american_football'
            ELSE provider
        END AS sport_code,
        COALESCE(daily_limit_per_sport, daily_limit_total, 100) AS request_limit
    FROM ops.provider_accounts
    WHERE is_active = TRUE
)
UPDATE ops.api_budget_status abs
SET
    requests_limit = pb.request_limit,
    last_updated = NOW()
FROM provider_budget pb
WHERE abs.sport_code = pb.sport_code
  AND abs.request_day = CURRENT_DATE;

WITH provider_budget AS (
    SELECT
        CASE
            WHEN provider = 'api_football' THEN 'football'
            WHEN provider = 'api_hockey' THEN 'hockey'
            WHEN provider = 'api_sport' THEN 'basketball'
            WHEN provider = 'api_tennis' THEN 'tennis'
            WHEN provider = 'api_volleyball' THEN 'volleyball'
            WHEN provider = 'api_handball' THEN 'handball'
            WHEN provider = 'api_baseball' THEN 'baseball'
            WHEN provider = 'api_rugby' THEN 'rugby'
            WHEN provider = 'api_cricket' THEN 'cricket'
            WHEN provider = 'api_american_football' THEN 'american_football'
            ELSE provider
        END AS sport_code,
        COALESCE(daily_limit_per_sport, daily_limit_total, 100) AS request_limit
    FROM ops.provider_accounts
    WHERE is_active = TRUE
)
INSERT INTO ops.api_budget_status (
    sport_code,
    request_day,
    requests_used,
    requests_limit,
    last_updated
)
SELECT
    pb.sport_code,
    CURRENT_DATE,
    0,
    pb.request_limit,
    NOW()
FROM provider_budget pb
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.api_budget_status abs
    WHERE abs.sport_code = pb.sport_code
      AND abs.request_day = CURRENT_DATE
);