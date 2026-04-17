-- Povolit basketball a hockey targety pro free test
UPDATE ops.ingest_targets
SET
    enabled = true,
    tier = 1,
    run_group = 'FREE_TEST_PRIMARY',
    max_requests_per_run = 1
WHERE sport_code IN ('basketball', 'hockey');

-- Football nechat jako maintenance
UPDATE ops.ingest_targets
SET
    enabled = true
WHERE sport_code = 'football'
  AND provider = 'api_football'
  AND provider_league_id IN ('39', '78', '140');

-- Vyčistit dnešní queue
DELETE FROM ops.scheduler_queue
WHERE queue_day = CURRENT_DATE;