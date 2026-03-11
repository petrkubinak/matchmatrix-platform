-- Football jen udržovací režim na free účtu
UPDATE ops.sports_import_plan
SET
    priority = 50,
    mode = 'daily',
    daily_request_budget = 20,
    max_parallel_jobs = 1,
    notes = 'FREE mode: maintenance only, seasons 2022-2024 already loaded for top 100 leagues'
WHERE sport_code = 'football';

-- Basketball a hockey dát výš pro test multi-sport pipeline
UPDATE ops.sports_import_plan
SET
    priority = 10,
    mode = 'daily',
    daily_request_budget = 40,
    max_parallel_jobs = 1,
    notes = 'FREE mode: primary test sport'
WHERE sport_code = 'basketball';

UPDATE ops.sports_import_plan
SET
    priority = 20,
    mode = 'daily',
    daily_request_budget = 40,
    max_parallel_jobs = 1,
    notes = 'FREE mode: primary test sport'
WHERE sport_code = 'hockey';

-- Dnešní budget přegenerovat
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