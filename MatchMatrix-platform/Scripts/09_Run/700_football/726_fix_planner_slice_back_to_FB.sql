UPDATE ops.ingest_planner
SET
    sport_code = 'FB',
    updated_at = NOW()
WHERE provider = 'api_football'
  AND sport_code = 'football'
  AND entity = 'fixtures'
  AND run_group = 'EU_top,EU_exact_v1';