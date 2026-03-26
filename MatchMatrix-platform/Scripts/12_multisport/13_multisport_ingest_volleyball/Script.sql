-- HOCKEY
UPDATE ops.ingest_planner
SET
    status = 'pending',
    attempts = 0,
    last_attempt = NULL,
    next_run = NOW(),
    updated_at = NOW()
WHERE provider = 'api_hockey'
  AND sport_code = 'HK'
  AND entity = 'teams';

-- BASKETBALL
UPDATE ops.ingest_planner
SET
    status = 'pending',
    attempts = 0,
    last_attempt = NULL,
    next_run = NOW(),
    updated_at = NOW()
WHERE provider = 'api_basketball'
  AND sport_code = 'BK'
  AND entity = 'teams';