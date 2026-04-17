UPDATE ops.ingest_targets
SET
    run_group = 'EU_top,EU_exact_v1',
    updated_at = NOW()
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND enabled = true
  AND run_group = 'FB_BOOTSTRAP_V1';