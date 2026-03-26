UPDATE ops.ingest_planner
SET
    status = 'pending',
    attempts = 0,
    last_attempt = NULL,
    next_run = NOW(),
    updated_at = NOW()
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity = 'teams'
  AND run_group = 'VB_CORE';