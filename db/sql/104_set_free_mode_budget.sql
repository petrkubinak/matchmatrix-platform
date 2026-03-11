-- FREE režim: 100 requestů / den / sport
UPDATE ops.sports_import_plan
SET
    daily_request_budget = 100,
    mode = 'daily'
WHERE enabled = true;

-- přegenerování dnešního budgetu podle aktuálního plánu
DELETE FROM ops.api_budget_status
WHERE request_day = CURRENT_DATE;

INSERT INTO ops.api_budget_status
(
    sport_code,
    request_day,
    requests_used,
    requests_limit,
    last_updated
)
SELECT
    sport_code,
    CURRENT_DATE,
    0,
    daily_request_budget,
    now()
FROM ops.sports_import_plan
WHERE enabled = true;